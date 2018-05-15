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

set -e
set -o nounset

LIB_DIR=$(realpath "$(dirname "${BASH_SOURCE}")")

source "$LIB_DIR"/config.sh
source "$LIB_DIR"/const.sh
source "$LIB_DIR"/docker.sh
source "$LIB_DIR"/etcd.sh
source "$LIB_DIR"/kube.sh
source "$LIB_DIR"/log.sh
source "$LIB_DIR"/nginx.sh
source "$LIB_DIR"/openstack.sh
source "$LIB_DIR"/promenade.sh
source "$LIB_DIR"/registry.sh
source "$LIB_DIR"/ssh.sh
source "$LIB_DIR"/validate.sh
source "$LIB_DIR"/virsh.sh

if [[ -v GATE_DEBUG && ${GATE_DEBUG} = "1" ]]; then
    set -x
fi
