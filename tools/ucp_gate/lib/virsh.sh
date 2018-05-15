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

img_base_declare() {
    log Validating base image exists
    if ! virsh vol-key --pool "${VIRSH_POOL}" --vol ucp-gate-base.img > /dev/null; then
        log Installing base image from "${BASE_IMAGE_URL}"

        cd "${TEMP_DIR}"
        curl -q -L -o base.img "${BASE_IMAGE_URL}"

        {
            virsh vol-create-as \
                --pool "${VIRSH_POOL}" \
                --name ucp-gate-base.img \
                --format qcow2 \
                --capacity "${BASE_IMAGE_SIZE}" \
                --prealloc-metadata
            virsh vol-upload \
                --vol ucp-gate-base.img \
                --file base.img \
                --pool "${VIRSH_POOL}"
        } &>> "${LOG_FILE}"
    fi
}

iso_gen() {
    NAME=${1}

    if virsh vol-key --pool "${VIRSH_POOL}" --vol "cloud-init-${NAME}.iso" &> /dev/null; then
        log Removing existing cloud-init ISO for "${NAME}"
        virsh vol-delete \
            --pool "${VIRSH_POOL}" \
            --vol "cloud-init-${NAME}.iso" &>> "${LOG_FILE}"
    fi

    log "Creating cloud-init ISO for ${NAME}"
    ISO_DIR=${TEMP_DIR}/iso/${NAME}
    mkdir -p "${ISO_DIR}"
    cd "${ISO_DIR}"

    BR_IP_NODE=$(config_vm_ip "${NAME}")
    SSH_PUBLIC_KEY=$(ssh_load_pubkey)
    export BR_IP_NODE
    export NAME
    export SSH_PUBLIC_KEY
    envsubst < "${TEMPLATE_DIR}/user-data.sub" > user-data
    envsubst < "${TEMPLATE_DIR}/meta-data.sub" > meta-data
    envsubst < "${TEMPLATE_DIR}/network-config.sub" > network-config

    {
        genisoimage \
            -V cidata \
            -input-charset utf-8 \
            -joliet \
            -rock \
            -o cidata.iso \
                meta-data \
                network-config \
                user-data

        virsh vol-create-as \
            --pool "${VIRSH_POOL}" \
            --name "cloud-init-${NAME}.iso" \
            --capacity "$(stat -c %s "${ISO_DIR}/cidata.iso")" \
            --format raw

        virsh vol-upload \
            --pool "${VIRSH_POOL}" \
            --vol "cloud-init-${NAME}.iso" \
            --file "${ISO_DIR}/cidata.iso"
    } &>> "${LOG_FILE}"
}

iso_path() {
    NAME=${1}
    echo "${TEMP_DIR}/iso/${NAME}/cidata.iso"
}

net_clean() {
    if virsh net-list --name | grep ^ucp_gate$ > /dev/null; then
        log Destroying ucp_gate network
        virsh net-destroy "${XML_DIR}/network.xml" &>> "${LOG_FILE}"
    fi
}

net_declare() {
    if ! virsh net-list --name | grep ^ucp_gate$ > /dev/null; then
        log Creating ucp_gate network
        virsh net-create "${XML_DIR}/network.xml" &>> "${LOG_FILE}"
    fi
}

pool_declare() {
    log Validating virsh pool setup
    if ! virsh pool-uuid "${VIRSH_POOL}" &> /dev/null; then
        log Creating pool "${VIRSH_POOL}"
        virsh pool-create-as --name "${VIRSH_POOL}" --type dir --target "${VIRSH_POOL_PATH}" &>> "${LOG_FILE}"
    fi
}

vm_clean() {
    NAME=${1}
    if virsh list --name | grep "${NAME}" &> /dev/null; then
        virsh destroy "${NAME}" &>> "${LOG_FILE}"
    fi

    if virsh list --name --all | grep "${NAME}" &> /dev/null; then
        log Removing VM "${NAME}"
        virsh undefine --remove-all-storage --domain "${NAME}" &>> "${LOG_FILE}"
    fi
}

vm_clean_all() {
    log Removing all VMs in parallel
    for NAME in "${ALL_VM_NAMES[@]}"; do
        vm_clean "${NAME}" &
    done
    wait
}

vm_create() {
    NAME=${1}
    iso_gen "${NAME}"
    vol_create_root "${NAME}"

    log Creating VM "${NAME}"
    DISK_OPTS="bus=virtio,cache=directsync,discard=unmap,format=qcow2"
    virt-install \
        --name "${NAME}" \
        --virt-type kvm \
        --cpu host \
        --graphics vnc,listen=0.0.0.0 \
        --noautoconsole \
        --network "network=ucp_gate,model=virtio" \
        --vcpus "$(config_vm_vcpus)" \
        --memory "$(config_vm_memory)" \
        --import \
        --disk "vol=${VIRSH_POOL}/ucp-gate-${NAME}.img,${DISK_OPTS}" \
        --disk "vol=${VIRSH_POOL}/cloud-init-${NAME}.iso,device=cdrom" &>> "${LOG_FILE}"

    ssh_wait "${NAME}"
    ssh_cmd "${NAME}" sync
}

vm_create_all() {
    log Starting all VMs in parallel
    for NAME in $(config_vm_names); do
        vm_create "${NAME}" &
    done
    wait

    for NAME in $(config_vm_names); do
        vm_validate "${NAME}"
    done
}

vm_start() {
    NAME=${1}
    log Starting VM "${NAME}"
    virsh start "${NAME}" &>> "${LOG_FILE}"
    ssh_wait "${NAME}"
}

vm_stop() {
    NAME=${1}
    log Stopping VM "${NAME}"
    virsh destroy "${NAME}" &>> "${LOG_FILE}"
}

vm_restart_all() {
    for NAME in $(config_vm_names); do
        vm_stop "${NAME}" &
    done
    wait

    for NAME in $(config_vm_names); do
        vm_start "${NAME}" &
    done
    wait
}

vm_validate() {
    NAME=${1}
    if ! virsh list --name | grep "${NAME}" &> /dev/null; then
        log VM "${NAME}" did not start correctly.
        exit 1
    fi
}


vol_create_root() {
    NAME=${1}

    if virsh vol-list --pool "${VIRSH_POOL}" | grep "ucp-gate-${NAME}.img" &> /dev/null; then
        log Deleting previous volume "ucp-gate-${NAME}.img"
        virsh vol-delete --pool "${VIRSH_POOL}" "ucp-gate-${NAME}.img" &>> "${LOG_FILE}"
    fi

    log Creating root volume for "${NAME}"
    virsh vol-create-as \
        --pool "${VIRSH_POOL}" \
        --name "ucp-gate-${NAME}.img" \
        --capacity 64G \
        --format qcow2 \
        --backing-vol ucp-gate-base.img \
        --backing-vol-format qcow2 &>> "${LOG_FILE}"
}
