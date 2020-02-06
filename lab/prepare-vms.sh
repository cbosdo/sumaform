#!/usr/bin/bash

. config/lab_env.cfg
. ../install_lab_env/config/include/colors.sh
. ../install_lab_env/config/include/global_vars.sh
. ../install_lab_env/config/include/common_functions.sh

export LIBVIRT_DEFAULT_URI=qemu:///system

# TODO Check for main.tf

# TODO Redefine HOL1313-net

# TODO Download sles15sp1.qcow2 in salt/virthost

# TODO If cleanup requested, run terraform destroy --auto-approve

# Run terraform apply --auto-approve
run terraform apply --auto-approve

# Script SUMA config as much a possible
SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.15.11"
run $SSH spacecmd -u admin -p admin -- activationkey_create -n SLE-15-SP1 -b sle-product-sles15-sp1-pool-x86_64 -d "SLE 15 SP1"
run $SSH spacecmd -u admin -p admin -- activationkey_addchildchannels 1-SLE-15-SP1 \
    sle-module-basesystem15-sp1-pool-x86_64 \
    sle-module-basesystem15-sp1-updates-x86_64 \
    sle-module-server-applications15-sp1-pool-x86_64 \
    sle-module-server-applications15-sp1-updates-x86_64 \
    sle-manager-tools15-pool-x86_64-sp1 \
    sle-manager-tools15-updates-x86_64-sp1 \
    sle-product-sles15-sp1-updates-x86_64

