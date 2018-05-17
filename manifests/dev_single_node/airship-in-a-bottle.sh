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

###############################################################################
#                                                                             #
# Set up and deploy a UCP environment for development/testing purposes.       #
# Many of the defaults and sources used here are NOT production ready, and    #
# this should not be used as a copy/paste source for any production use.      #
#                                                                             #
###############################################################################

echo "Welcome to Airship in a Bottle"
echo " /--------------------\\"
echo "|                      \\"
echo "|        |---|          \\----"
echo "|        | x |                \\"
echo "|        |---|                 |"
echo "|          |                  /"
echo "|     \____|____/       /----"
echo "|                      /"
echo " \--------------------/"
sleep 1
echo ""
echo "The minimum recommended size of the VM is 4 vCPUs, 16GB of RAM with 64GB disk space."
sleep 1
echo "Let's collect some information about your VM to get started."
sleep 1

# IP and Hostname setup
HOST_IFACE=$(ip route | grep "^default" | head -1 | awk '{ print $5 }')
read -p "Is your HOST IFACE $HOST_IFACE? (y/n) " YN_HI
if [ "$YN_HI" != "y" ]; then
  read -p "What is your HOST IFACE? " HOST_IFACE
fi

LOCAL_IP=$(ip addr | awk "/inet/ && /${HOST_IFACE}/{sub(/\/.*$/,\"\",\$2); print \$2}")
read -p "Is your LOCAL IP $LOCAL_IP? (y/n) " YN_IP
if [ "$YN_IP" != "y" ]; then
  read -p "What is your LOCAL IP? " LOCAL_IP
fi

# Updates the /etc/hosts file
echo "Updating /etc/hosts with: ${LOCAL_IP} $(hostname)"
cat << EOF | sudo tee -a /etc/hosts
${LOCAL_IP} $(hostname)
EOF

# Saves the old IFS, updates to a new one to split the IP.
# x.0/24 is the CIDR needed by CEPH.
OLDIFS=$IFS
IFS='.' read -r -a array <<< "$LOCAL_IP"
CIDR="${array[0]}.${array[1]}.${array[2]}.0/24"
read -p "Is your HOST CIDR $CIDR? (y/n) " YN_CIDR
if [ "$YN_CIDR" != "y" ]; then
  read -p "What is your HOST CIDR? " CIDR
fi
# Resets the IFS to be safe.
IFS=$OLDIFS

# Variable setup
# The hostname for the genesis node
export HOSTNAME=$(hostname)
echo "exporting HOSTNAME=$HOSTNAME"
# The IP address of the genesis node
export HOSTIP=$LOCAL_IP
echo "exporting HOSTIP=$HOSTIP"
# The CIDR of the network for the genesis node
export HOSTCIDR=$CIDR
echo "exporting HOSTCIDR=$HOSTCIDR"
# The network interface on the genesis node
export NODE_NET_IFACE=$HOST_IFACE
echo "exporting NODE_NET_IFACE=$NODE_NET_IFACE"

export TARGET_SITE="dev"
echo "exporting TARGET_SITE=$TARGET_SITE"

echo ""
echo "Starting Airship deployment..."
sleep 1
./deploy-ucp.sh
