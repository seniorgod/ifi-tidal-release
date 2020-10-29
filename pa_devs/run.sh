#!/bin/bash
FULL_PATH=$(realpath ${0})
THIS_NAME=${FULL_PATH##*/}
SAME_DIR=${FULL_PATH%${THIS_NAME}}

${SAME_DIR}/bin/ifi-pa-devs-get > ${SAME_DIR}devices
