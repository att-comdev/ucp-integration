rsync_cmd() {
    rsync -e "ssh -F ${SSH_CONFIG_DIR}/config" "${@}"
}

ssh_cmd() {
    HOST=${1}
    shift
    args=$(shell-quote -- "${@}")
    if [[ -v GATE_DEBUG && ${GATE_DEBUG} = "1" ]]; then
        ssh -F "${SSH_CONFIG_DIR}/config" -v "${HOST}" "${args}"
    else
        ssh -F "${SSH_CONFIG_DIR}/config" "${HOST}" "${args}"
    fi
}

ssh_config_declare() {
    log Validating SSH config exists
    if [ ! -s "${SSH_CONFIG_DIR}/config" ]; then
        log Creating SSH config
        env -i \
            "SSH_CONFIG_DIR=${SSH_CONFIG_DIR}" \
            envsubst < "${TEMPLATE_DIR}/ssh-config.sub" > "${SSH_CONFIG_DIR}/config"
    fi
}

ssh_keypair_declare() {
    log Validating SSH keypair exists
    if [ ! -s "${SSH_CONFIG_DIR}/id_rsa" ]; then
        log Generating SSH keypair
        ssh-keygen -N '' -f "${SSH_CONFIG_DIR}/id_rsa" &>> "${LOG_FILE}"
    fi
}

ssh_load_pubkey() {
    cat "${SSH_CONFIG_DIR}/id_rsa.pub"
}

ssh_setup_declare() {
    mkdir -p "${SSH_CONFIG_DIR}"
    ssh_keypair_declare
    ssh_config_declare
}

ssh_wait() {
    NAME=${1}
    while ! ssh_cmd "${NAME}" /bin/true; do
        sleep 0.5
    done
}
