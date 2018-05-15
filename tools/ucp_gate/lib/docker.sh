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

docker_ps() {
    VIA="${1}"
    ssh_cmd "${VIA}" docker ps -a
}

docker_info() {
    VIA="${1}"
    ssh_cmd "${VIA}" docker info 2>&1
}

docker_exited_containers() {
    VIA="${1}"
    ssh_cmd "${VIA}" docker ps -q --filter "status=exited"
}

docker_inspect() {
    VIA="${1}"
    CONTAINER_ID="${2}"
    ssh_cmd "${VIA}" docker inspect "${CONTAINER_ID}"
}

docker_logs() {
    VIA="${1}"
    CONTAINER_ID="${2}"
    ssh_cmd "${VIA}" docker logs "${CONTAINER_ID}"
}
