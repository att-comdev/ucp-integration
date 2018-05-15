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

export GENESIS_NAME=n0
export SSH_CONFIG_DIR=${WORKSPACE}/tools/ucp_gate/config-ssh
export TEMPLATE_DIR=${WORKSPACE}/tools/ucp_gate/templates
export XML_DIR=${WORKSPACE}/tools/ucp_gate/xml
export ALL_VM_NAMES=(
    n0
    n1
    n2
    n3
)
