# Properly place shared disk images
ARCHIVE_TYPE=$(get_archive_type "${VM_SRC_DIR}/shared")
echo -e "${LTBLUE}Extracting VMs shared images...${NC}"
extract_archive "${VM_SRC_DIR}/shared" ${VM_DEST_DIR}/${COURSE_NUM} ${ARCHIVE_TYPE}

run sudo sh -c "echo -e '192.168.15.11	srv.hol1313.net		srv' >>/etc/hosts"
run sudo sh -c "echo -e '192.168.15.12	kvm1.hol1313.net	kvm1' >>/etc/hosts"
run sudo sh -c "echo -e '192.168.15.13	kvm2.hol1313.net	kvm2' >>/etc/hosts"
run sudo sh -c "echo -e '192.168.15.14	monitoring.hol1313.net	monitoring' >>/etc/hosts"

echo -e "${LTBLUE}Starting virtual machines...${NC}"
for VM in $LIBVIRT_VM_LIST; do
    run virsh start $VM
done
