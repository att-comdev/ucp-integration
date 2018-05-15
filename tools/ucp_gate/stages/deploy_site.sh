#!/usr/bin/env bash

set -e

cd /root/deploy/site && source creds.sh
./root/deploy/site/run_shipyard.sh create configdocs design --filename=/home/shipyard/host/deployment_files.yaml
./root/deploy/site/run_shipyard.sh create configdocs secrets --filename=/home/shipyard/host/certificates.yaml --append
./root/deploy/site/run_shipyard.sh commit configdocs
./root/deploy/site/run_shipyard.sh create action deploy_site
