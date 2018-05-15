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

validate_cluster() {
    NAME=${1}

    log Validating cluster via VM "${NAME}"
    rsync_cmd "${TEMP_DIR}/scripts/validate-cluster.sh" "${NAME}:/root/promenade/"
    ssh_cmd "${NAME}" /root/promenade/validate-cluster.sh
}

validate_etcd_membership() {
    CLUSTER=${1}
    VM=${2}
    shift 2
    EXPECTED_MEMBERS="${*}"

    # NOTE(mark-burnett): Wait a moment for disks in test environment to settle.
    sleep 10
    log Validating "${CLUSTER}" etcd membership via "${VM}"
    FOUND_MEMBERS=$(etcdctl_member_list "${CLUSTER}" "${VM}" | tr '\n' ' ' | sed 's/ $//')

    if [[ "x${EXPECTED_MEMBERS}" != "x${FOUND_MEMBERS}" ]]; then
        log Etcd membership check failed for cluster "${CLUSTER}"
        log "Found \"${FOUND_MEMBERS}\", expected \"${EXPECTED_MEMBERS}\""
        exit 1
    fi
}
