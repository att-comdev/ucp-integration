#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(realpath $(dirname $0))
WORKSPACE=$(realpath ${SCRIPT_DIR}/../../..)
GATE_UTILS=${WORKSPACE}/tools/ucp_gate/lib/all.sh

source ${GATE_UTILS}

exec ssh -F ${SSH_CONFIG_DIR}/config $@
