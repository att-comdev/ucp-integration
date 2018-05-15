#!/usr/bin/env bash
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

source "${GATE_UTILS}"

OUTPUT_DIR="${TEMP_DIR}/config"
mkdir -p "${OUTPUT_DIR}"
chmod 777 "${OUTPUT_DIR}"
OUTPUT_FILE="${OUTPUT_DIR}/combined.yaml"

CERTIFICATES_FILE="${OUTPUT_DIR}/certificates.yaml"
OLD_CERTIFICATES_FILE="${OUTPUT_DIR}/certificates-old.yaml"

IS_UPDATE=0
DO_EXCLUDE=0
EXCLUDE_PATTERNS=()

while getopts "ux:" opt; do
    case "${opt}" in
        u)
            IS_UPDATE=1
            ;;
        x)
            DO_EXCLUDE=1
            EXCLUDE_PATTERNS+=("${OPTARG}")
            ;;
        *)
            echo "Unknown option"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

function should_include_filename() {
    FILENAME="${1}"
    if [[ ${DO_EXCLUDE} == 1 ]]; then
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if echo "${FILENAME}" | grep "${pattern}" > /dev/null; then
                return 1
            fi
        done
    fi
    return 0
}

# Ensure we do not duplicate configuration on update.
rm -f "${OUTPUT_FILE}"

for source_dir in $(config_configuration); do
    log Copying configuration from "${source_dir}"
    for filename in ${WORKSPACE}/${source_dir}/*.yaml; do
        if should_include_filename "${filename}"; then
            log Including config from "$filename"
            cat "${filename}" >> "${OUTPUT_FILE}"
        else
            log Excluding config from "$filename"
        fi
    done
done

if [[ ${IS_UPDATE} == "1" && -e ${CERTIFICATES_FILE} ]]; then
    mv "${CERTIFICATES_FILE}" "${OLD_CERTIFICATES_FILE}"
fi

log "Setting up local caches.."
nginx_cache_and_replace_tar_urls "${OUTPUT_DIR}"/*.yaml
registry_replace_references "${OUTPUT_DIR}"/*.yaml

FILES=($(ls "${OUTPUT_DIR}"))

log Generating certificates
docker run --rm -t \
    -w /target \
    -v "${OUTPUT_DIR}:/target" \
    -e "PROMENADE_DEBUG=${PROMENADE_DEBUG}" \
    "${IMAGE_PROMENADE}" \
        promenade \
            generate-certs \
                -o /target \
                "${FILES[@]}"

if [[ -e "${OLD_CERTIFICATES_FILE}" ]]; then
    rm -f "${OLD_CERTIFICATES_FILE}"
fi

mkdir -p "${NGINX_DIR}"
cat "${TEMP_DIR}"/config/*.yaml > "${TEMP_DIR}/nginx/promenade.yaml"
