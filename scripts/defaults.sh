#!/bin/bash



# Default vars. '4SCREEN vars should stay before regular not to be overwritten'
JAIL_NAME_4SCREEN=${COLOR_GREEN}${JAIL_NAME:-${COLOR_BLUE}"MediaBox"}${COLOR_N}
JAIL_NAME=${JAIL_NAME:-"MediaBox"}
INTERFACE=${INTERFACE:-"vnet0"}
if [ ! -z "$JAIL_IP" ]
then
    JAIL_IP_4SCREEN=${COLOR_GREEN}$(awk -F"." '{print $1"."$2"."$3".'${JAIL_IP:-$SUGGESTED_LAST_OCTET_OF_IP}'"}'<<<${AUTO_GW_IP})${COLOR_N}
else
    JAIL_IP_4SCREEN=${COLOR_BLUE}$(awk -F"." '{print $1"."$2"."$3".'${JAIL_IP:-$SUGGESTED_LAST_OCTET_OF_IP}'"}'<<<${AUTO_GW_IP})${COLOR_N}
fi
JAIL_IP=$(awk -F"." '{print $1"."$2"."$3".'${JAIL_IP:-$SUGGESTED_LAST_OCTET_OF_IP}'"}'<<<${AUTO_GW_IP})
SHARES_4SCREEN=( ${COLOR_GREEN}"${SHARES[@]:-${COLOR_BLUE}"no-share-defined"}"${COLOR_N} )
SHARES=( "${SHARES[@]:-"no-share-defined"}" )
BKP_PATH_4SCREEN=${COLOR_GREEN}${BKP_PATH:-${COLOR_BLUE}$DBACKUP}${COLOR_N}
BKP_PATH=${BKP_PATH:-$DBACKUP}
FIND_BKP_FILE=$(ls -dt ${BKP_PATH}/bkp* | head -1 | xargs -n 1 basename 1>/dev/null)
BKP_FILE_4SCREEN=${COLOR_GREEN}${FIND_BKP_FILE:-${COLOR_RED}"no-backup-yet"}${COLOR_N}
BKP_FILE=${FIND_BKP_FILE:-"no-backup-yet"}
RELEASE_4SCREEN=${COLOR_GREEN}${RELEASE:-${COLOR_BLUE}$AUTO_RELEASE}${COLOR_N}
RELEASE=${RELEASE:-$AUTO_RELEASE}



# Params for jail creation
VNET="on"
VNET_DEFAULT_INTERFACE="none"
DHCP="off"
BPF="yes"
BOOT="on"
ALLOW_RAW_SOCKETS="1"
ALLOW_TUN="1"



# Loading defaults for specific versions; updated as they appear
echo -ne "${INFO} Getting defaults for ${COLOR_BLUE}FreeNAS ${OS_VERSION}${COLOR_N}... "
source $DIR/scripts/${OS_VERSION}/defaults.sh
echo -e ${OK}

