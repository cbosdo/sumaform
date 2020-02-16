#!/usr/bin/bash

. config/lab_env.cfg
. ../install_lab_env/config/include/colors.sh
. ../install_lab_env/config/include/global_vars.sh
. ../install_lab_env/config/include/common_functions.sh

export LIBVIRT_DEFAULT_URI=qemu:///system

# Shutdown all VMs
echo -e "${LTBLUE}Shutting down VMs...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
VMs="srv kvm1 kvm2 monitoring"
DO_SHUTDOWN=
for VM in $VMs; do
    if test "$(virsh list | grep ' $VM ' | wc -l)" != "0"; then
        DO_SHUTDOWN="yes"
        run virsh shutdown $VM
    fi
done

if test "$DO_SHUTDOWN" = "yes"; then
    sleep 30
fi

# We were already patient enough!
for VM in $VMs; do
    if test "$(virsh list | grep ' $VM ' | wc -l)" != "0"; then
        echo -e "${ORANGE}Forcing ${VM} down since it didn't shutdown after 30s${NC}"
        run virsh destroy $VM
    fi
done

# Prepare all course folders we need
echo -e "${LTBLUE}Preparing the folders ...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
run mkdir -p ${VM_DEST_DIR} ${ISO_DEST_DIR} ${PDF_DEST_DIR} ${SCRIPTS_DEST_DIR} ${COURSE_FILES_DEST_DIR} \
    ${IMAGE_DEST_DIR}/${COURSE_NUM}

run rm -rf ${VM_DEST_DIR}/${COURSE_NUM} \
    ${ISO_DEST_DIR}/${COURSE_NUM} \
    ${PDF_DEST_DIR}/${COURSE_NUM} \
    ${SCRIPTS_DEST_DIR}/${COURSE_NUM} \
    ${COURSE_FILES_DEST_DIR}/${COURSE_NUM} \

run mkdir -p ${SCRIPTS_DEST_DIR}/${COURSE_NUM}/config
run cp -r ../install_lab_env/config/include ${SCRIPTS_DEST_DIR}/${COURSE_NUM}/config
for conf in $(ls config); do
    run cp -r ${PWD}/config/${conf} ${SCRIPTS_DEST_DIR}/${COURSE_NUM}/config
done
run cp ../install_lab_env/*.sh ${SCRIPTS_DEST_DIR}/${COURSE_NUM}

# Get the JeOS image to image dir
echo -e "${LTBLUE}Ensuring we have the JeOS image...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
JEOS_IMAGE=${IMAGE_DEST_DIR}/${COURSE_NUM}/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen.qcow2
if test ! -e ${JEOS_IMAGE}; then
    run curl -o ${JEOS_IMAGE} http://dist.suse.de/install/SLE-15-SP1-JeOS-QU2/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen-QU2.qcow2
fi

# Copy VM images to lab/VMs
echo -e "${LTBLUE}Copying VMs...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
VMS_DIR=${VM_DEST_DIR}/${COURSE_NUM}

for VM in srv kvm monitoring; do
    VM_NAME=${COURSE_NUM}-${VM}
    run mkdir -p ${VMS_DIR}/${VM_NAME}/
    virsh dumpxml $VM > ${VMS_DIR}/${VM_NAME}/${VM_NAME}.xml
    cat << EOF > vm-cleanup-script.sed
/<uuid>/d;
s/<name>${VM}</<name>${VM_NAME}</;
s|<source pool='[^']\+' volume='\([^']\+\)'/>|<source file='${VMS_DIR}/${VM_NAME}/\1'/>|;
s/type='volume'/type='file'/
s/machine='[^']\+'/machine='pc'/
EOF
    run sed -i -f vm-cleanup-script.sed ${VMS_DIR}/${VM_NAME}/${VM_NAME}.xml
    run rm vm-cleanup-script.sed

    DISK_PATH=$(virsh vol-path ${VM}-main-disk default)
    run cp --sparse=always ${DISK_PATH} ${VMS_DIR}/${VM_NAME}/

    BACKING_FILE_PATH=$(qemu-img info --output json --backing-chain ${DISK_PATH} | grep full-backing-filename | sed 's/^[^:]\+: "\([^"]\+\)",/\1/')
    BACKING_FILE_NAME=$(basename $BACKING_FILE_PATH)
    if test ! -f ${VMS_DIR}/shared/${BACKING_FILE_NAME}; then
        run mkdir -p ${VMS_DIR}/shared
        run cp ${BACKING_FILE_PATH} ${VMS_DIR}/shared/
        run sudo chmod g+rw ${VMS_DIR}/shared/${BACKING_FILE_NAME}
        run sudo chown :qemu ${VMS_DIR}/shared/${BACKING_FILE_NAME}
    fi
    run qemu-img rebase -b ${VMS_DIR}/shared/${BACKING_FILE_NAME} ${VMS_DIR}/${VM_NAME}/${VM}-main-disk
    run chmod g+rw ${VMS_DIR}/${VM_NAME}/${VM}-main-disk
    run sudo chown :qemu ${VMS_DIR}/${VM_NAME}/${VM}-main-disk
done

# Copy / Link SSH keys and config to lab/config/ssh
echo -e "${LTBLUE}Copying SSH keys...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
run cp ../salt/controller/id_rsa* ${SCRIPTS_DEST_DIR}/${COURSE_NUM}/config/ssh/

echo -e "${LTBLUE}Generating documentation...${NC}"
echo -e "${LTBLUE}---------------------------------------------------------${NC}"
run mkdir -p ${PDF_DEST_DIR}/${COURSE_NUM}
run pandoc pdf/instructions.md -s --highlight-style zenburn -o ${PDF_DEST_DIR}/${COURSE_NUM}/instructions.pdf

run sh ../install_lab_env/backup_lab_env.sh
