#!/bin/bash

#  name:        informix_install.sh:
#  description: Install Informix on Ubuntu
#  url:         https://github.com/0x1fff/docker-informix
#
#  usage:       Please run as root!
#               ./informix_install.sh iif.12.10.FC3IE.linux-x86_64.tar
#
#  Detailed Desription:
#   - Upgrades system and fetches Informix dependencies
#   - Unpacks archive with Informix
#   - Installs Informix in given location
#
#  What is missing (TODO):
#   - No start scripts
#   - DATA_DIR should be outside Docker container
#

ARCHIVE_PATH=$1
UNPACK_DIR=/opt/IBM/informix-src
INSTALL_DIR=/opt/IBM/informix
DATA_DIR=/home/informix
INSTANCE_NAME=dev
USER_PASS="ifx_pass"
IFXDB_VERSION=""
IFX_INSTALL_ARGS="-i silent"

echo "###############################################"
echo "# IBM Informix Installation script for Ubuntu #"
echo "###############################################"

function myfatal {
	if [ "${1}" -ne 0 ] ; then
		echo "${2}" >&2
		exit $1
	fi
}

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

. /etc/lsb-release
echo ">>>    OS version: "${DISTRIB_DESCRIPTION}
echo ">>>    Upgrading OS and installing dependencies for Informix ${IFXDB_VERSION}"
apt-get update  -qy
myfatal $? "apt-get update failed"
apt-get upgrade -qy
myfatal $? "apt-get upgrade failed"
apt-get install -qy libaio1 bc pdksh libncurses5 ncurses-bin libpam0g
myfatal $? "apt-get dependencies failed"
apt-get install -qy adduser file build-essential
myfatal $? "apt-get build-essential failed"

echo ">>>    Create group and user for Informix"
groupadd informix -g 200 >/dev/null
useradd -m -d "${DATA_DIR}" -g informix -u 200 informix  >/dev/null
adduser informix sudo  >/dev/null
echo "informix:${USER_PASS}" | chpasswd

# echo "$(tput setaf 1)Set informix password$(tput sgr0)"
# passwd informix
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
   sed -i "s#UserInformixInfo.Homedir=.*#UserInformixInfo.Homedir=${DATA_DIR}#g"    ${BUNDLE_FILE}
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
	myfatal 253 "Installation failed: no bin directory in ${INSTALL_DIR}"
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

echo ">>>    Postconfig sqlhost ..."
if [ ! `grep onsoctcp "${SQLHOSTS_PATH}" | wc -l` -ne 0 ] ; then
	echo "${INSTANCE_NAME}        onsoctcp        *               sqlexec" >> "${SQLHOSTS_PATH}"
fi

echo ">>>    Include tcp support ..."
if [ ! `grep sqlexec /etc/services | wc -l` -ne 0 ] ; then
    echo -e 'sqlexec\t9088/tcp' >>/etc/services
fi



echo ">>>    Create informix user environnement"
cat <<EOF > "${DATA_DIR}"/ifx_${INSTANCE_NAME}.env
export INFORMIXSERVER=${INSTANCE_NAME}
export INFORMIXDIR="${INSTALL_DIR}"
export INFORMIXTERM=terminfo
export ONCONFIG=onconfig.dev
export INFORMIXSQLHOSTS="\${INFORMIXDIR}/etc/sqlhosts.dev"
export CLIENT_LOCALE=en_US.utf8
export DB_LOCALE=en_US.utf8
export DBDATE=Y4MD-
export DBDELIMITER='|';
export PATH=\${INFORMIXDIR}/bin:\${INFORMIXDIR}/lib:\${INFORMIXDIR}/lib/esql:\${PATH}
export LD_LIBRARY_PATH=\${INFORMIXDIR}/lib:\$INFORMIXDIR/lib/esql:\$INFORMIXDIR/lib/tools
export PS1="IDS-${IFXDB_VERSION} ${INSTANCE_NAME}: "
export MSGPATH=""${DATA_DIR}"/logs/informix.log"
EOF

echo ">>>    Create directory structure"
mkdir -p "${DATA_DIR}"/logs
mkdir -p "${DATA_DIR}"/backup/datas
mkdir -p "${DATA_DIR}"/backup/logs
mkdir -p "${DATA_DIR}"/spaces/dbs_root/
touch "${DATA_DIR}"/spaces/dbs_root/dbs_root.000
chmod 660 "${DATA_DIR}"/spaces/dbs_root/dbs_root.000

echo ">>>    Chown directory structure"
chown informix: "${INSTALL_DIR}"/etc/*.dev 
chown -R informix: "${DATA_DIR}"/{logs,backup,spaces}
chmod -R 777 "${DATA_DIR}"/backup
chown informix: "${DATA_DIR}"/ifx_dev.env

# Add user enviroment to .bashrc
echo "">> "${DATA_DIR}"/.bashrc
echo ". ${DATA_DIR}/ifx_dev.env" >>"${DATA_DIR}"/.bashrc

echo ">>>    Deleting unpacked files"
rm -rf "${UNPACK_DIR}"

echo "###############################################"
echo "#         Installation completed              #"
echo "###############################################"
echo " * Switch to Informix user with: su - informix"
echo " * Initialize engine with: oninit -ivy"
echo " * Check if engine is Online with: onstat -l"
echo "###############################################"
