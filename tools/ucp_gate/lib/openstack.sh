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

os_ks_get_token() {
    VIA=${1}
    KEYSTONE_URL=${2:-http://keystone-api.ucp.svc.cluster.local}
    DOMAIN=${3:-default}
    USERNAME=${4:-promenade}
    PASSWORD=${5:-password}

    REQUEST_BODY_PATH="ks-token-request.json"
    cat <<EOBODY > "${TEMP_DIR}/${REQUEST_BODY_PATH}"
{
    "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "${USERNAME}",
          "domain": { "id": "${DOMAIN}" },
          "password": "${PASSWORD}"
        }
      }
    }
  }
}
EOBODY

    rsync_cmd "${TEMP_DIR}/${REQUEST_BODY_PATH}" "${VIA}:/root/${REQUEST_BODY_PATH}"

    ssh_cmd "${VIA}" curl -isS \
      --fail \
      --max-time 60 \
      --retry 10 \
      --retry-delay 15 \
      -H 'Content-Type: application/json' \
      -d "@/root/${REQUEST_BODY_PATH}" \
      "${KEYSTONE_URL}/v3/auth/tokens" | grep 'X-Subject-Token' | awk '{print $2}' | sed "s;';;g" | sed "s;\r;;g"
}
