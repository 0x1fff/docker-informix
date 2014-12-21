#!/bin/bash
#
#  name:        informix_start.sh:
#  description: Starts Informix in Docker container
#  url:         https://github.com/0x1fff/docker-informix
#

set -o pipefail

export INFORMIX_HOME="/home/informix/"
export INFORMIX_DATA_DIR="${INFORMIX_HOME}/data/"
export MYINFORMIX_DBSPACE="dbs_root"

source "${INFORMIX_HOME}/.bashrc"
source "${INFORMIX_HOME}/ifx_dev.env"

function myfatal {
	if [ "${1}" -ne 0 ] ; then
		echo "${2}" >&2
		exit $1
	fi
}



if [ ! -e "${INFORMIX_DATA_DIR}/.initialized" ] ; then
	echo ">>>    Create data directory structure in ${INFORMIX_DATA_DIR} (ifx initialization)"
	mkdir -p "${INFORMIX_DATA_DIR}"/logs
	mkdir -p "${INFORMIX_DATA_DIR}"/backup/datas
	mkdir -p "${INFORMIX_DATA_DIR}"/backup/logs
	mkdir -p "${INFORMIX_DATA_DIR}"/spaces/dbs_root/
	touch "${INFORMIX_DATA_DIR}"/spaces/dbs_root/dbs_root.000

	chown -R informix: "${INFORMIX_DATA_DIR}"/{logs,backup,spaces}
	chmod 660 "${INFORMIX_DATA_DIR}"/spaces/dbs_root/dbs_root.000
	chmod -R 777 "${INFORMIX_DATA_DIR}"/backup

	# Initialize shared memmory and data structure
	# and kill server
	oninit -iy && touch "${INFORMIX_DATA_DIR}/.initialized"
	onmode -ky
fi



DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}

DB_INFO_FILE="${INFORMIX_HOME}/informix_dbinfo.sh"
IFX_CREATE="NO"
## Create new user
if [ ! -e "${DB_INFO_FILE}" ] && [ ! -z "${DB_USER}" ] && [ ! -z "${DB_PASS}" ] &&  [ ! -z "${DB_NAME}" ] ; then
	IFX_CREATE="YES"
	echo -e "IFX_DB_NAME=${DB_NAME}\n"\
			"IFX_DB_USER=${DB_USER}\n"\
			"IFX_DB_PASS=${DB_PASS}\n" > "${DB_INFO_FILE}.run"

fi

if [ "${IFX_CREATE}" = "YES" ] ; then
	# Check if user exists: id -u "${DB_USER}"
	echo ">>>    Create user \"${DB_USER}\"..."
	sudo useradd ${USER_ADD_CREATE_HOME} -d "${INFORMIX_HOME}" "${DB_USER}"  >/dev/null
	myfatal $? "User creation failed"
	
	echo "${DB_USER}:${DB_PASS}" | sudo chpasswd
	myfatal $? "Changing password failed"
fi

echo ">>>    Starting up the IBM Informix Database (${INFORMIXSERVER}) ... "
oninit -y
myfatal $? "*** Startup of ${INFORMIXSERVER} FAILED***"
echo "*** Startup of ${INFORMIXSERVER} SUCCESS ***"

## Create database and grant DBA
if [ "${IFX_CREATE}" = "YES" ] ; then
	echo ">>>    Create database \"${DB_NAME}\"..."
	echo "CREATE DATABASE ${DB_NAME} IN ${MYINFORMIX_DBSPACE} WITH BUFFERED LOG" | dbaccess > /dev/null 2>&1
	myfatal $? "CREATE DATABASE ${DB_NAME} FAILED"

	echo ">>>    Grant DBA to database \"${DB_NAME}\" for user \"${DB_USER}\"..."
	echo "GRANT DBA TO ${DB_USER};" | dbaccess "${DB_NAME}" > /dev/null 2>&1
	myfatal $? "GRANT DBA FAILED"

	mv "${DB_INFO_FILE}.run" "${DB_INFO_FILE}"
fi


if [ -e "${DB_INFO_FILE}" ] ; then 
	source "${DB_INFO_FILE}"
	onstat -V
	echo -e "\t#################################################\n"\
    	    "\t# Informix container login information:          \n"\
       	 	"\t#   database:    ${IFX_DB_NAME}                  \n"\
       	 	"\t#   user:        ${IFX_DB_USER}                  \n"\
        	"\t#   password:    ${IFX_DB_PASS}                  \n"\
        	"\t#################################################\n" 
fi

# run interactive shell now it is done in Dockerfile
# echo ">>>    Starting shell"
# bash

