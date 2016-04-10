#!/bin/bash

#  name:        informix_install.sh:
#  description: Install Informix on Debian
#  url:         https://github.com/0x1fff/docker-informix
#
#  usage:       Please run as root!
#               ./informix_install.sh iif.12.10.FC3IE.linux-x86_64.tar
#
#  Detailed Description:
#   - Upgrades Debian based system and fetches Informix dependencies
#   - Unpacks archive with Informix
#   - Installs Informix in given location
#

ARCHIVE_PATH=$1
UNPACK_DIR=/opt/IBM/informix-src
INSTALL_DIR=/opt/IBM/informix

USER_HOME="/home/informix/"
USER_HOME="${USER_HOME%/}" # Strip the trailing /

DATA_DIR="${USER_HOME}/data/"
DATA_DIR="${DATA_DIR%/}" # Strip the trailing /

INSTANCE_NAME="dev"
USER_NAME="informix"
USER_PASS="ifx_pass"
USER_UID=200

GROUP_NAME="${USER_NAME}"
GROUP_GID=200

# Delete downloaded data including packages
DO_CLEANUP="YES"


##
## Changing lines below at your own risk!
##
IFXDB_VERSION=""
IFX_INSTALL_ARGS="-i silent"


echo "###############################################"
echo "# IBM Informix Installation script for Debian #"
echo "###############################################"

function myfatal {
	if [ "${1}" -ne 0 ] ; then
		echo "${2}" >&2
		exit $1
	fi
}

## TODO: Add code to download Informix from public ftp/http
if [ $# -ne 1 ] ; then
    myfatal 255 "usage: "$0" <informix_file.tar>"
fi


if [ ! -f "${ARCHIVE_PATH}" -o ! -r "${ARCHIVE_PATH}" ] ; then
    myfatal 254 "File "$1" is not readable file"
fi

case "${ARCHIVE_PATH}" in

	*11.50*)
		IFXDB_VERSION="11.50"
		BUNDLE_FILE=bundle.ini
		IFX_INSTALL_ARGS="-silent -acceptlicense=yes -debug -disable-checks -log install_log.txt"
		;;

	*11.70*) 
		IFXDB_VERSION="11.70"
		BUNDLE_FILE=bundle.properties
		IFX_INSTALL_ARGS="-i silent -f ${UNPACK_DIR}/${BUNDLE_FILE} -DLICENSE_ACCEPTED=TRUE"
		;;

	*12.10*)
		IFXDB_VERSION="12.10"
		BUNDLE_FILE=bundle.properties
		IFX_INSTALL_ARGS="-i silent -f ${UNPACK_DIR}/${BUNDLE_FILE} -DLICENSE_ACCEPTED=TRUE"
		;;

	*) 
		myfatal 100 "This Informix version is not supported!"
		;;
esac

# Get DISTRIB_DESCRIPTION
DISTRIB_DESCRIPTION=`uname -a`
KERNEL_VERSION=`uname -a`
if [ -e /etc/lsb-release ] ; then
	. /etc/lsb-release
elif [ -e /etc/debian_version ] ; then
	DISTRIB_DESCRIPTION="Debian "`cat /etc/debian_version`
fi

echo ">>>    OS version: ${DISTRIB_DESCRIPTION}"
echo ">>>    Linux Kernel version: ${KERNEL_VERSION}"
echo ">>>    Upgrading OS and installing dependencies for Informix ${IFXDB_VERSION}"
apt-get update  -qy
myfatal $? "apt-get update failed"
apt-get upgrade -qy
myfatal $? "apt-get upgrade failed"
apt-get install -qy apt-utils adduser file sudo
myfatal $? "apt-get install apt-utils adduser file"
apt-get install -qy libaio1 bc pdksh libncurses5 ncurses-bin libpam0g
myfatal $? "apt-get dependencies failed"

echo ">>>    Create group and user for Informix"
id "${USER_NAME}" 2>/dev/null >/dev/null
if [ $? -eq 0 ] ; then
	myfatal 253 "User ${USER_NAME} exists"
fi

USER_ADD_CREATE_HOME=""
if [ ! -d "${USER_HOME}" ] ; then
	USER_ADD_CREATE_HOME="-m"
fi

groupadd "${GROUP_NAME}" -g "${GROUP_GID}" >/dev/null
myfatal $? "Adding group ${GROUP_NAME} ID:${GROUP_GID} failed"

useradd ${USER_ADD_CREATE_HOME} -d "${USER_HOME}" -g "${GROUP_NAME}" -u "${USER_UID}" "${USER_NAME}"  >/dev/null
myfatal $? "Adding user ${USER_NAME} ID:${USER_UID} HOME:${USER_HOME} failed"

adduser "${USER_NAME}" sudo  >/dev/null
myfatal $? "Adding user ${USER_NAME} to sudo group failed"

echo "${USER_NAME}:${USER_PASS}" | chpasswd

echo ">>>    Uncompress Informix Archive: $ARCHIVE_PATH"
mkdir -p "${UNPACK_DIR}" "${INSTALL_DIR}"
tar -C "${UNPACK_DIR}" -xf "${ARCHIVE_PATH}"
myfatal $? "Unable to unpack $ARCHIVE_PATH"

echo ">>>    Launch silent install ..."

cd "${UNPACK_DIR}"
if [ "${IFXDB_VERSION}" = "11.50" ] ; then
   cp ${BUNDLE_FILE} ${BUNDLE_FILE}.bak
   sed -i 's/licenseAccepted=false/licenseAccepted=true/g'                          ${BUNDLE_FILE}
   sed -i 's/csdk.active=false/csdk.active=true/g'                                  ${BUNDLE_FILE}
   sed -i "s#UserInformixInfo.Homedir=.*#UserInformixInfo.Homedir=${DATA_DIR}/#g"    ${BUNDLE_FILE}
   sed -i "s#installLocation=.*#installLocation=${INSTALL_DIR}#g"                   ${BUNDLE_FILE}
   sed -i "s/UserInformixInfo.Password=.*/UserInformixInfo.Password=${USER_PASS}/g" ${BUNDLE_FILE}
   #   sed 's/demoinput.CreateDemo="nocreate"/demoinput.CreateDemo="create"/g'
   #   sed "s/demoinput4.ServerName=.*/demoinput4.ServerName=${INSTANCE_NAME}/g"
   #   sed "s#demoinput4.rootpath=.*#demoinput4.rootpath=${DATA_DIR}/spaces/dbs_root/dbs_root.000#g"
fi

if [ -e ${BUNDLE_FILE} ] ; then
	cp ${BUNDLE_FILE} ${BUNDLE_FILE}.bak
	
	echo -n ""                                       > ${BUNDLE_FILE}
	echo USER_INSTALL_DIR="${INSTALL_DIR}"          >> ${BUNDLE_FILE}
	echo LICENSE_ACCEPTED=TRUE                      >> ${BUNDLE_FILE}
	echo IDS_INSTALL_TYPE=CUSTOM                    >> ${BUNDLE_FILE}
	grep ^CHOSEN_FEATURE_LIST bundle.properties.bak >> ${BUNDLE_FILE}
	#echo IDS_INFORMIXSERVER=${INSTANCE_NAME}        >> ${BUNDLE_FILE}
	#echo IDS_DRDA_BOOLEAN_1=0                       >> ${BUNDLE_FILE}
    # echo CHOSEN_FEATURE_LIST=IDS,IDS-SVR,IDS-EXT,IDS-EXT-JAVA,IDS-EXT-OPT,IDS-EXT-CNV,IDS-EXT-XML,IDS-DEMO,IDS-ER,IDS-LOAD,IDS-LOAD-ONL,IDS-LOAD-DBL,IDS-LOAD-HPL,IDS-BAR,IDS-BAR-CHK,IDS-BAR-ONBAR,IDS-BAR-TSM,IDS-ADM,IDS-ADM-PERF,IDS-ADM-MON,IDS-ADM-ADT,IDS-ADM-IMPEXP,IDS-JSON,GLS,GLS-WEURAM,GLS-EEUR,GLS-CHN,GLS-JPN,GLS-KOR,GLS-OTH,SDK,SDK-CPP,SDK-CPP-DEMO,SDK-ESQL,SDK-ESQL-DEMO,SDK-ESQL-ACM,SDK-LMI,SDK-ODBC,SDK-ODBC-DEMO,JDBC >> ${BUNDLE_FILE}
    # echo #If you want to create an instance as part of installation, uncomment the following line (DEFAULT: No)
    # echo #IDS_SERVER_INSTANCE_BOOLEAN_1=1
    # echo #Uncomment the following line if you do NOT want the instance to be initialized (DEFAULT: Initialize instance)
    # echo #IDS_INIT_SERVER_BOOLEAN_1=0
fi

./ids_install ${IFX_INSTALL_ARGS}
myfatal $? "Installation failed please check /tmp/bundle* files for more info"

if [ ! -d "${INSTALL_DIR}/bin/" ] ; then
	myfatal 252 "Installation failed: no bin directory in ${INSTALL_DIR}"
fi

ONCONFIG_PATH="${INSTALL_DIR}"/etc/onconfig."${INSTANCE_NAME}"
SQLHOSTS_PATH="${INSTALL_DIR}"/etc/sqlhosts."${INSTANCE_NAME}"
cp "${INSTALL_DIR}"/etc/onconfig.std "${ONCONFIG_PATH}"
cp "${INSTALL_DIR}"/etc/sqlhosts.std "${SQLHOSTS_PATH}"

echo ">>>    Postconfig onconfig ..."
sed -i 's#ROOTNAME rootdbs#ROOTNAME dbs_root#g'                            "${ONCONFIG_PATH}"
sed -i "s#ROOTPATH .*#ROOTPATH ${DATA_DIR}/spaces/dbs_root/dbs_root.000#g" "${ONCONFIG_PATH}"
sed -i "s#CONSOLE .*#CONSOLE ${DATA_DIR}/logs/console.log#g"               "${ONCONFIG_PATH}"
sed -i "s#MSGPATH .*#MSGPATH ${DATA_DIR}/logs/online.log#g"                "${ONCONFIG_PATH}"
sed -i "s#DBSERVERNAME.*#DBSERVERNAME ${INSTANCE_NAME}#g"                  "${ONCONFIG_PATH}"
sed -i "s#DEF_TABLE_LOCKMODE page#DEF_TABLE_LOCKMODE row#g"                "${ONCONFIG_PATH}"
sed -i "s#TAPEDEV .*#TAPEDEV   ${DATA_DIR}/backup/datas#g"                 "${ONCONFIG_PATH}"
sed -i "s#LTAPEDEV .*#LTAPEDEV ${DATA_DIR}/backup/logs#g"                  "${ONCONFIG_PATH}"
chown "${USER_NAME}:" "${ONCONFIG_PATH}"

echo ">>>    Postconfig sqlhost ..."
if [ ! `grep onsoctcp "${SQLHOSTS_PATH}" | wc -l` -ne 0 ] ; then
	echo "${INSTANCE_NAME}        onsoctcp        *               sqlexec" >> "${SQLHOSTS_PATH}"
fi
chown "${USER_NAME}:" "${SQLHOSTS_PATH}"

echo ">>>    Include tcp support ..."
if [ ! `grep sqlexec /etc/services | wc -l` -ne 0 ] ; then
    echo -e 'sqlexec\t9088/tcp' >>/etc/services
fi

echo ">>>    Create Informix user environnement"
cat <<EOF > "${USER_HOME}/ifx_${INSTANCE_NAME}.env"
export INFORMIXSERVER=${INSTANCE_NAME}
export INFORMIXDIR="${INSTALL_DIR}"
export INFORMIXTERM=terminfo
export ONCONFIG=onconfig.${INSTANCE_NAME}
export INFORMIXSQLHOSTS="\${INFORMIXDIR}/etc/sqlhosts.${INSTANCE_NAME}"
export CLIENT_LOCALE=en_US.utf8
export DB_LOCALE=en_US.utf8
export DBDATE=Y4MD-
export DBDELIMITER='|';
export PATH=\${INFORMIXDIR}/bin:\${INFORMIXDIR}/lib:\${INFORMIXDIR}/lib/esql:\${PATH}
export LD_LIBRARY_PATH=\${INFORMIXDIR}/lib:\$INFORMIXDIR/lib/esql:\$INFORMIXDIR/lib/tools
export PS1="IDS-${IFXDB_VERSION} ${INSTANCE_NAME}: "
export MSGPATH=""${DATA_DIR}"/logs/informix.log"
EOF
chown "${USER_NAME}:" "${USER_HOME}/ifx_${INSTANCE_NAME}.env"

echo ">>>    Create data directory"
mkdir -p "${DATA_DIR}"
chown -R "${USER_NAME}:" "${DATA_DIR}"

# Add user enviroment to .bashrc
echo "" >> "${USER_HOME}/.bashrc"
echo ". ${USER_HOME}/ifx_${INSTANCE_NAME}.env" >>"${USER_HOME}/.bashrc"

echo ">>>    Deleting unpacked files"
rm -rf "${UNPACK_DIR}"
myfatal $? "rm ${UNPACK_DIR} failed"

if [ "${DO_CLEANUP}" == "YES" ] ; then
	echo ">>>    Deleting downloaded packages"
	rm -rf /var/lib/apt/lists/*
	myfatal $? "rm /var/lib/apt/lists/ failed"
	rm -rf /var/cache/apt/archives/*
	myfatal $? "rm /var/cache/apt/archives/ failed"
fi

echo "###############################################"
echo "#         Installation completed              #"
echo "###############################################"
