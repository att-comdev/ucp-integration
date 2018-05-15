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

CONFIG_PROXY=${HTTP_PROXY:-}

log Building docker image "${IMAGE_PROMENADE}"

if [[ -z "$CONFIG_PROXY" ]]
then
  docker build -q \
    --network host \
    -t "${IMAGE_PROMENADE}" \
    "${WORKSPACE}"
else
    docker build -q \
      --network host \
      -t "${IMAGE_PROMENADE}" \
      --build-arg "HTTP_PROXY=${HTTP_PROXY:-}" \
      --build-arg "HTTPS_PROXY=${HTTPS_PROXY:-}" \
      --build-arg "NO_PROXY=${NO_PROXY:-}" \
      --build-arg "http_proxy=${http_proxy:-}" \
      --build-arg "https_proxy=${https_proxy:-}" \
      --build-arg "no_proxy=${no_proxy:-}" \
      "${WORKSPACE}"
fi

log Loading Promenade image "${IMAGE_PROMENADE}" into local registry
docker tag "${IMAGE_PROMENADE}" "localhost:5000/${IMAGE_PROMENADE}" &>> "${LOG_FILE}"
docker push "localhost:5000/${IMAGE_PROMENADE}" &>> "${LOG_FILE}"
