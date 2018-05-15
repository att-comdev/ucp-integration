#!/usr/bin/env bash

set -e

source "${GATE_UTILS}"

cd "${TEMP_DIR}"
mkdir scripts

# Create setup_genesis.sh script
cat << EOF > ${TEMP_DIR}/scripts/setup_genesis.sh
#!/bin/bash

mkdir -p /root/deploy
cp /root/ucp/virtmgr_id_rsa /root/deploy/
cd /root/deploy && git clone http://github.com/att-comdev/ucp-integration
cd /root/deploy/ucp-integration && git fetch https://review.gerrithub.io/att-comdev/ucp-integration refs/changes/41/409541/1 && git checkout FETCH_HEAD

EOF

# Copy virtmgr private key
cp /home/virtmgr/.ssh/id_rsa ${TEMP_DIR}/scripts/virtmgr_id_rsa

# Change permissions of setup_genesis.sh script
chmod 777 ${TEMP_DIR}/scripts/setup_genesis.sh

# Copies script and virtmgr private key to genesis VM
rsync_cmd "${TEMP_DIR}/scripts/setup_genesis.sh" "${GENESIS_NAME}:/root/ucp/"
rsync_cmd "${TEMP_DIR}/scripts/virtmgr_id_rsa" "${GENESIS_NAME}:/root/ucp/"

set -o pipefail
ssh_cmd "${GENESIS_NAME}" /root/promenade/genesis.sh 2>&1 | tee -a "${LOG_FILE}"
set +o pipefail

if ! ssh_cmd n0 docker images | tail -n +2 | grep -v registry:5000 ; then
    log_warn "Using some non-cached docker images.  This will slow testing."
    ssh_cmd n0 docker images | tail -n +2 | grep -v registry:5000 | tee -a "${LOG_FILE}"
fi
