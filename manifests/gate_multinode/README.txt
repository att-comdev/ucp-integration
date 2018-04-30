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

gate_multinode
===============

To be run on a libvirt hypervisor with 4 VMs - n0, n1, n2, n3 - created.

1. Collects the site definition for gate-multinode via Pegleg
2. Runs the genesis process on n0 via Promenade
3. Loads the site definition into Deckhand via Shipyard
4. Runs deploy_site via Shipyard to deploy n1, n2 and n3 via Drydock/MAAS

Running deploy-ucp will download and build into the /root/deploy directory.

Process
-------
1) TODO - Automate this setup process
    1a) Setup a Linux bridge ucp_gate
    1b) Configure a veth interface pair and add the peer to your bridge
    1c) Address your veth interface with 172.24.1.1
    1d) Configure a SNAT rule to allow VM access to the physical network
    1e) Create a user 'virtmgr' and add it to the group for libvirt
    1f) Generate a SSH keypair and add the public key to ~virtmgr/.ssh/authorized_keys
    1g) Save the private key for step 4d below
2) TODO - Automate the VM creation process
    2a) Download the Ubuntu 16.04 cloud image
    2b) Create VM n0 as a 4x16GB VM with a 64GB root disk of Ubuntu 16.04.
        NOTE: MAC address must be '52:54:00:00:a3:31'
    2d) Create VMs n1, n2, n3 as 4x8GB VM with a 64GB root disk volume, blank
        NOTE: MAC addresses must be '52:54:00:00:a3:31', '52:54:00:1a:95:0d',
        '52:54:00:31:c2:36' respectively.
    2e) Connect all 4 VMs to the ucp_gate bridge
    2f) Start n0
3) Connect to n0 and become root. All the commands are run as root.
4) On n0 go to /root and clone ucp integration in /root/deploy. Pull the latest patchset if needed
    4a) mkdir -p /root/deploy
    4b) cd /root/deploy && git clone http://github.com/att-comdev/ucp-integration
    4c) Optionally apply a Gerrit patchset
    4d) Configure your virtmgr private key by updating
        /root/deploy/ucp-integration/site/gate-multinode/secrets/passphrases/ucp_drydock_kvm_ssh_key.yaml
        with the private key generated in 1g.
5) cd into /root/deploy/ucp-integration/manifests/gate_multinode
6) source set-env.sh

NOTE: If running this behind a corporate proxy, you will need to update the
      file deployment_files/site/gate-multinode/networks/common-addresses.yaml to
      specify your proxy server and appropriate no_proxy list.
7) ./deploy-ucp.sh

If you want to stop the deployment before it starts running genesis and inspect
the produced files, comment the last few lines of the deploy-ucp.sh to not
trigger the genesis steps.

Next Steps
----------
All of the documents used for a subsequent deploy_site action are now placed
into the /root/deploy/site directory for ease of use - instructions are
provided by the script at the end of a successful genesis process.

In the same directory as the deploy-ucp.sh script, there is a file creds.sh
that can be sourced to set environment variables that will enable keystone
authoriation to use for running shipyard.

Example:

. creds.sh


The files produced into the /root/deploy/genesis directory contain two yaml
files: certificates.yaml and deployment_files.yaml. These files can be used as
input to shipyard using the script found at /root/deploy/shipyard/tools/run_shipyard.sh

Example: (assuming creds.sh is sourced as above)

cd /root/deploy/site
# Note that /home/shipyard/host is where the host's pwd is mounted in the shipyard container.
./run_shipyard.sh create configdocs design --filename=/home/shipyard/host/deployment_files.yaml
./run_shipyard.sh create configdocs secrets --filename=/home/shipyard/host/certificates.yaml --append
./run_shipyard.sh commit configdocs
./run_shipyard.sh create action deploy_site
