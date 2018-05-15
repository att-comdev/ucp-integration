# Copyright 2018 AT&T Intellectual Property.  All other rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export TEMP_DIR=${TEMP_DIR:-$(mktemp -d)}
export BASE_IMAGE_SIZE=${BASE_IMAGE_SIZE:-68719476736}
export BASE_IMAGE_URL=${BASE_IMAGE_URL:-https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img}
export IMAGE_PROMENADE=${IMAGE_PROMENADE:-quay.io/attcomdev/promenade:latest}
export NGINX_DIR="${TEMP_DIR}/nginx"
export NGINX_URL="http://172.24.1.1:7777"
export PROMENADE_BASE_URL="http://promenade-api.ucp.svc.cluster.local"
export PROMENADE_DEBUG=${PROMENADE_DEBUG:-0}
export REGISTRY_DATA_DIR=${REGISTRY_DATA_DIR:-/mnt/registry}
export VIRSH_POOL=${VIRSH_POOL:-ucp_gate}
export VIRSH_POOL_PATH=${VIRSH_POOL_PATH:-/var/lib/libvirt/ucp_gate}

config_configuration() {
    jq -cr '.configuration[]' < "${GATE_MANIFEST}"
}

config_vm_memory() {
    jq -cr '.vm.memory' < "${GATE_MANIFEST}"
}

config_vm_names() {
    jq -cr '.vm.names[]' < "${GATE_MANIFEST}"
}

config_vm_ip() {
    NAME=${1}
    echo "172.24.1.1${NAME:1}"
}

config_vm_vcpus() {
    jq -cr '.vm.vcpus' < "${GATE_MANIFEST}"
}
