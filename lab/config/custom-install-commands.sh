# Properly place shared disk images
ARCHIVE_TYPE=$(get_archive_type "${VM_SRC_DIR}/shared")
echo -e "${LTBLUE}Extracting VMs shared images...${NC}"
extract_archive "${VM_SRC_DIR}/shared" ${VM_DEST_DIR}/${COURSE_NUM} ${ARCHIVE_TYPE}
