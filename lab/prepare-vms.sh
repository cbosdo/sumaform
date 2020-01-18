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

# TODO Run terraform apply --auto-approve

# TODO Script SUMA config as much a possible

