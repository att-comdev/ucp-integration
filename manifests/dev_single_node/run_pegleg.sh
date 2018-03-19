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

# Clone Pegleg from github
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

# Install requirements for Pegleg
function install_pegleg {
  cd ~/pegleg/src/bin/pegleg
  pip3 install -r requirements.txt
}

# Create Pegleg image
function make_image {
  cd ~/pegleg
  make
}

# Run Pegleg against a selected site to produce an output file
function run_pegleg {
  cd
  export WORKSPACE=~/ucp-integration/
  export IMAGE=quay.io/attcomdev/pegleg:latest
  cd pegleg/tools
  ./pegleg.sh site -p /workspace/deployment_files collect dev -s /workspace
}

# Remove venv3.5 and pegleg directories
function clean {
  cd
  rm -fr venv3.5
  rm -fr pegleg
}

# Verify deployment_files.yaml was actually created
function verify_success {
  if [ -f "$WORKSPACE"deployment_files.yaml ]
  then
    echo "Successfully created config file!"
  else
    error "verifying success. Config file is not found"
  fi
}

# Processes errors
function error {
  echo "Error when $1."
  exit 1
}


trap clean EXIT

retrieve_pegleg || error "cloning Pegleg"
create_venv3.5 || error "creating Python 3.5 virtual environment"
install_pegleg || error "installing the requirements for pegleg"
make_image || error "creating Pegleg image"
run_pegleg || error "creating config file against site using pegleg"
verify_success || error "verifying success"
