#!/usr/bin/env bash

set -e

source "${GATE_UTILS}"

cd "${TEMP_DIR}"

# Create deckhand_load.sh script
cat << EOF > ${TEMP_DIR}/scripts/deckhand_load.sh
#!/bin/bash

cd /root/deploy/site && source creds.sh
./root/deploy/site/run_shipyard.sh create configdocs design --filename=/home/shipyard/host/deployment_files.yaml
./root/deploy/site/run_shipyard.sh create configdocs secrets --filename=/home/shipyard/host/certificates.yaml --append
./root/deploy/site/run_shipyard.sh commit configdocs

EOF

# Create deploy_site.sh script
cat << EOF > ${TEMP_DIR}/scripts/deploy_site.sh
#!/bin/bash

cd /root/deploy/site && source creds.sh
./root/deploy/site/run_shipyard.sh create action deploy_site

EOF

# Change permissions of setup_genesis.sh script
chmod 777 ${TEMP_DIR}/scripts/*.sh

# Copies script and virtmgr private key to genesis VM
rsync_cmd "${TEMP_DIR}/scripts/deckhand_load.sh" "${GENESIS_NAME}:/root/ucp/"
rsync_cmd "${TEMP_DIR}/scripts/deploy_site.sh" "${GENESIS_NAME}:/root/ucp/"

set -o pipefail
ssh_cmd "${GENESIS_NAME}" /root/ucp/deckhand_load.sh 2>&1 | tee -a "${LOG_FILE}"
ssh_cmd "${GENESIS_NAME}" /root/ucp/deploy_site.sh 2>&1 | tee -a "${LOG_FILE}"
set +o pipefail
