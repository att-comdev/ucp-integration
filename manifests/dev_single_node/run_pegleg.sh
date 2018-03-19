#!/bin/bash
#
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

set -x

# Clone pegleg from github in root directory
function retrieve_pegleg {
  cd
  git clone https://github.com/att-comdev/pegleg.git
}

# Create py 3.5 virtual environment and activate it
function create_venv3.5 {
  cd
  virtualenv -p python3 venv3.5
  source venv3.5/bin/activate
}

# Install requirements for pegleg
function install_pegleg {
  cd
  cd pegleg/src/bin/pegleg
  pip3 install -r requirements.txt
  cd
  cd pegleg
  make
}

# Run pegleg against a selected site to produce an output file
function run_pegleg {
  cd
  export WORKSPACE=$(pwd)/ucp-integration/deployment_files
  export IMAGE=quay.io/attcomdev/pegleg:latest
  cd pegleg/tools
  ./pegleg.sh site -p /workspace collect dev -s /workspace
}

# Remove venv3.5 and pegleg directories
function clean {
  cd
  sudo rm -fr venv3.5
  sudo rm -fr pegleg
}


trap clean EXIT

retrieve_pegleg
create_venv3.5
install_pegleg
run_pegleg
