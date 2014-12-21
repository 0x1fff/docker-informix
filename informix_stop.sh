#!/bin/bash
#
#  name:        informix_start.sh:
#  description: Stops Informix in Docker container
#  url:         https://github.com/0x1fff/docker-informix
#

set -o pipefail

export INFORMIX_HOME="/home/informix/"
export INFORMIX_DATA_DIR="${INFORMIX_HOME}/data/"

source "${INFORMIX_HOME}/.bashrc"
source "${INFORMIX_HOME}/ifx_dev.env"

function myfatal {
    if [ "${1}" -ne 0 ] ; then
        echo "${2}" >&2
        exit $1
    fi
}

echo ">>>    Stopping the IBM Informix Database (${INFORMIXSERVER}) ... "

onmode -ky
myfatal $? "*** Shutdown of ${INFORMIXSERVER} FAILED***"
echo "*** Shutdown of ${INFORMIXSERVER} SUCCESS ***"
