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

dev_single_node
===============

Sets up and deploys an instance of UCP using the images pinned in the versions
file of the targeted deployment_files based site definitions.
versions file: deployment_files/global/v1.0u/software/config/versions.yaml

Running deploy-ucp will download and build into the /root/deploy directory.

Process
-------
1) Set up as large a VM as you can reasonably set up. 8 core/16GB is
   recommended
2) become root. All the commands are run as root.
3) update etc/hosts with IP/Hostname of your VM. e.g. 10.0.0.15 testvm1
4) go to /root and clone ucp integration. Pull the latest patchset if needed
5) cd /root/ucp-integration/manifests/dev_single_node
6) Update the set-env.sh with the hostname and ip on the appropriate lines.
7) set the UCP integration repo and refspec to the gerrithub & patchset of the
   deployment you want to use.

E.g.:

export UCP_INTEGRATION_REPO="https://review.gerrithub.io/att-comdev/ucp-integration"
export UCP_INTEGRATION_REFSPEC="refs/changes/03/404203/21"

8) set the pegleg image, since :latest is not right as of 3/21/2018

export PEGLEG_IMAGE="artifacts-aic.atlantafoundry.com/att-comdev/pegleg:f019b4ff594db7d13a2ac444c001f867b3a67c50"```

9) source set-env.sh
10)  Run deploy-ucp.sh

If you want to stop the deployment before it starts running genesis and inspect
the produced files, comment the last few lines of the deploy-ucp.sh to not
trigger the genesis steps.