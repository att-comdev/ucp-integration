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

nginx_down() {
    REGISTRY_ID=$(docker ps -qa -f name=ucp-gate-nginx)
    if [ "x${REGISTRY_ID}" != "x" ]; then
        log Removing nginx server
        docker rm -fv "${REGISTRY_ID}" &>> "${LOG_FILE}"
    fi
}

nginx_up() {
    log Starting nginx server to serve configuration files
    mkdir -p "${NGINX_DIR}"
    docker run -d \
        -p 7777:80 \
        --restart=always \
        --name ucp-gate-nginx \
        -v "${TEMP_DIR}/nginx:/usr/share/nginx/html:ro" \
            nginx:stable &>> "${LOG_FILE}"
}

nginx_cache_and_replace_tar_urls() {
    log "Finding tar_url options to cache.."
    TAR_NUM=0
    mkdir -p "${NGINX_DIR}"
    for file in "$@"; do
        grep -Po "^ +tar_url: \K.+$" "${file}" | while read tar_url ; do
            # NOTE(mark-burnet): Does not yet ignore repeated files.
            DEST_PATH="${NGINX_DIR}/cached-tar-${TAR_NUM}.tgz"
            log "Caching ${tar_url} in file: ${DEST_PATH}"
            REPLACEMENT_URL="${NGINX_URL}/cached-tar-${TAR_NUM}.tgz"
            curl -Lo "${DEST_PATH}" "${tar_url}"
            sed -i "s;${tar_url};${REPLACEMENT_URL};" "${file}"
            TAR_NUM=$((TAR_NUM + 1))
        done
    done
}
