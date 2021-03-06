#!/bin/bash
# OpenVPN jail install script

function InstallMediaBox {

	set -e

	trap ErrorHandling ERR INT

	echo
	CheckConfigDirs # Create config dir(s) if doesn't exist(s) already

	CheckIocageJail # Check if already exists
	if [ $JAIL_EXIST == "false" ]; then
		# Create jail with Custom vars
		echo
		echo -ne "${PROGRESS} ${JAIL_NAME} jail creation in progress... "
		iocage create \
			-n ${JAIL_NAME} \
			ip4_addr="${INTERFACE}|${JAIL_IP}/24" \
			defaultrouter=${AUTO_GW_IP} \
			dhcp=${DHCP} \
			bpf=${BPF} \
			vnet=${VNET} \
			vnet_default_interface=${VNET_DEFAULT_INTERFACE} \
			boot=${BOOT} \
			allow_mount=${ALLOW_MOUNT} \
			allow_mount_devfs=${ALLOW_MOUNT_DEVFS} \
			allow_raw_sockets=${ALLOW_RAW_SOCKETS} \
			allow_tun=${ALLOW_TUN} \
			ip6=${IP6} \
			-r ${RELEASE};
		# Manual install packages due to need of updating repos first
		echo
		echo -e "${INFO} Updating packages... "
		iocage exec "${JAIL_NAME}" env ASSUME_ALWAYS_YES=YES pkg bootstrap
		iocage exec "${JAIL_NAME}" pkg upgrade -y
		iocage exec "${JAIL_NAME}" pkg update -y
		echo -e "${INFO} Installing 'nano|openvpn|mpack'... "
		iocage exec "${JAIL_NAME}" pkg install -y nano openvpn mpack
		echo -e "${OK} $JAIL_NAME jail successfully created!"
	fi

	

	source $DIR/scripts/dirs_for_jail.sh # dirs path for MediaBox
	source $DIR/scripts/files_for_jail.sh # copy & configure all files for MediaBox
	source $DIR/scripts/server.sh # copy & configure all files for OpenVPN server
	
	MapShares  # create map all shares to MediaBox



	# Remove old 'openvpn-configs' dir and copy the new one in jail
	echo
	echo -ne "${PROGRESS} copy conf dir to jail... "
	rm -rf "${IOCAGE_PATH}/root/root/openvpn-configs"
	if \cp -r "${DCONFIG}" "${IOCAGE_PATH}/root/root/openvpn-configs"; then
    	echo -e "${OK}"
	else
		echo -e "${FAIL}"
	fi



	# Restart jail
	RestartJail



	# Sending clients via e-mail
	cat <<-EOF | xargs -L1 iocage exec "${JAIL_NAME}"
	echo
	service sendmail onestart
	cd ${JAIL_DCLIENTS}
	find ${JAIL_DCLIENTS} -maxdepth 1 -type f -exec tar czvf OpenVPN-Clients.tar.gz {} +
	echo Sending e-mail from Charlie Root<root@localhost.my.domain> to ${EMAIL}
	mpack -s 'OpenVPN profiles/clients' OpenVPN-Clients.tar.gz ${EMAIL}
	EOF


	echo
	echo -e "${COLOR_GREEN}Installation Complete!${COLOR_N}"
	echo
	echo -e "${INFO} Make sure you forward external port ${EXT_PORT} to internal IP ${JAIL_IP} on PORT 1194"
	echo -e "${INFO} You cand log into ${JAIL_NAME} jail with 'iocage console ${JAIL_NAME}'"
	echo



	# no need to exit/trap on errors anymore
	set +e
	trap - ERR INT



	echo
	CheckOVPNServer # Check if server is up and running; showing last lines from log.

} >$FLOG 2>&1

