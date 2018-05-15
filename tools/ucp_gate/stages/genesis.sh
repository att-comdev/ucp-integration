#!/usr/bin/env bash

set -e

source "${GATE_UTILS}"

cd "${TEMP_DIR}"
mkdir scripts

# Create setup_genesis.sh script
cat << EOF > ${TEMP_DIR}/scripts/setup_genesis.sh
#!/bin/bash

# Set up /etc/hosts
echo '172.24.1.10 n0' >> /etc/hosts

# Create deploy directory and git clone the required repositories
mkdir -p /root/deploy
cd /root/deploy && git clone http://github.com/att-comdev/ucp-integration
cd /root/deploy/ucp-integration && git fetch https://review.gerrithub.io/att-comdev/ucp-integration refs/changes/41/409541/1 && git checkout FETCH_HEAD

# Update ucp_drydock_kvm_ssh_key.yaml
cp /root/ucp/ucp_drydock_kvm_ssh_key.yaml /root/deploy/ucp-integration/deployment_files/site/gate-multinode/secrets/passphrases/ucp_drydock_kvm_ssh_key.yaml

# Execute deploy-ucp.sh script
cd /root/deploy/ucp-integration/manifests/gate_multinode && source set-env.sh && ./deploy-ucp.sh

EOF

# Create ucp_drydock_kvm_ssh_key.yaml
cat << EOF > ${TEMP_DIR}/scripts/ucp_drydock_kvm_ssh_key.yaml
---
schema: deckhand/CertificateKey/v1
metadata:
  schema: metadata/Document/v1
  name: ucp_drydock_kvm_ssh_key
  layeringDefinition:
    layer: site
    abstract: false
  storagePolicy: cleartext
data: |-
EOF

# Copy virtmgr private key
cp /home/virtmgr/.ssh/id_rsa ${TEMP_DIR}/scripts/virtmgr_id_rsa

# Add 2 spaces in front so that we can append the content to ucp_drydock_kvm_ssh_key.yaml
# Append virtmgr private key to ucp_drydock_kvm_ssh_key.yaml
# Delete the virtmgr private key that is in the temporary directory
sed -i -e 's/^/  /' ${TEMP_DIR}/scripts/virtmgr_id_rsa
cat ${TEMP_DIR}/scripts/virtmgr_id_rsa >> ${TEMP_DIR}/scripts/ucp_drydock_kvm_ssh_key.yaml
echo "..." >> ${TEMP_DIR}/scripts/ucp_drydock_kvm_ssh_key.yaml
rm ${TEMP_DIR}/scripts/virtmgr_id_rsa

# Change permissions of setup_genesis.sh script
chmod 777 ${TEMP_DIR}/scripts/setup_genesis.sh

# Copies script and virtmgr private key to genesis VM
rsync_cmd "${TEMP_DIR}/scripts/setup_genesis.sh" "${GENESIS_NAME}:/root/ucp/"
rsync_cmd "${TEMP_DIR}/scripts/ucp_drydock_kvm_ssh_key.yaml" "${GENESIS_NAME}:/root/ucp/"

set -o pipefail
ssh_cmd "${GENESIS_NAME}" /root/ucp/setup_genesis.sh 2>&1 | tee -a "${LOG_FILE}"
set +o pipefail

if ! ssh_cmd n0 docker images | tail -n +2 | grep -v registry:5000 ; then
    log_warn "Using some non-cached docker images.  This will slow testing."
    ssh_cmd n0 docker images | tail -n +2 | grep -v registry:5000 | tee -a "${LOG_FILE}"
fi
