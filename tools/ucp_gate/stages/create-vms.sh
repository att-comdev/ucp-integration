#!/usr/bin/env bash

set -e

source "${GATE_UTILS}"

vm_clean_all
vm_create "n0" "52:54:00:96:86:10"
vm_create "n1" "52:54:00:00:a3:31"
vm_create "n2" "52:54:00:1a:95:0d"
vm_create "n3" "52:54:00:31:c2:36"
