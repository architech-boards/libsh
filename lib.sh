#!/bin/bash
# Script library


#######################################################################################################################
# gets form user the sudo password and exports it
function get_sudo_password
{
	local ZENITY_INSTALLED=`dpkg-query -l | grep zenity-common |& awk -F" " '{ print $1 }'`

	if [ "${USER}" != "architech" -o "${HOME}" != "/home/architech" ] 
	then
	    SUDO_PASSWORD="wrong"
	    while [ "${SUDO_PASSWORD}" != "${SUDO_PASSWORD2}" ]; 
	    do
		if [ "${ZENITY_INSTALLED}" != "ii" ]
		then
			echo "Please enter sudo password: "
			read -s SUDO_PASSWORD
			echo "Please confirm sudo password: "
			read -s SUDO_PASSWORD2
		else
			SUDO_PASSWORD=`zenity --password --text "Please enter sudo password: "`
			SUDO_PASSWORD2=`zenity --password --text "Please confirm sudo password: "`
		fi
	    done
	else
	    SUDO_PASSWORD="architech"
	fi

	export SUDO_PASSWORD
}

#######################################################################################################################
# execute a command with sudo privileges
function do_sudo
{
	CMD=$1
	stty -echo
	echo -e ${SUDO_PASSWORD} | sudo -S bash -c "${CMD}"
	stty echo
}
