#!/usr/bin/bash

. config/lab_env.cfg
. ../install_lab_env/config/include/colors.sh
. ../install_lab_env/config/include/global_vars.sh
. ../install_lab_env/config/include/common_functions.sh

export LIBVIRT_DEFAULT_URI=qemu:///system

# Check for main.tf
if test ! -e 'main.tf'; then
    echo "Copy and adapt lab/main.tf.hol1313 as main.tf"
    exit 1
fi

# Cleanup if requested
if test "$1" == "--clean"; then
    terraform destroy --auto-approve
    run virsh net-undefine HOL1313-net
fi

# Define HOL1313-net if needed
virsh net-info HOL1313-net >/dev/null 2>&1
if "x$?" == "x1"; then
    run virsh net-define lab/config/libvirt.cfg/HOL1313-net.xml
fi

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

exit 0
