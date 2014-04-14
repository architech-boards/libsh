#!/bin/bash
# Script library

#######################################################################################################################
# Global variables used:
# SUDO_PASSWORD		- password of sudo
# DEBUG_LOG_LEVEL	- debug level

#######################################################################################################################
# Defines used: error codes
readonly ERROR_INTERNET=1
readonly ERROR_COMMAND=2
readonly ERROR_SPECIFIC=3

#######################################################################################################################
# INIT SCRIPT
# set debug log level [ 0 none, 2 verbose ]

while getopts "D:v" option
do
    case ${option} in
	D)
	    DEBUG_LOG_LEVEL=${OPTARG}
	    [ ${DEBUG_LOG_LEVEL} -lt 0 ] && { DEBUG_LOG_LEVEL=0; }
	    [ ${DEBUG_LOG_LEVEL} -gt 2 ] && { DEBUG_LOG_LEVEL=2; }
	;;
	*)
	    DEBUG_LOG_LEVEL=0
	;;
    esac
done

#######################################################################################################################
# return 1 if user is "architech" 0 else
function is_architech_user
{
	[ "${USER}" == "architech" -a "${HOME}" == "/home/architech" ] && { return 1; }
	return 0;
}

#######################################################################################################################
# gets form user the sudo password and exports it
# param: none
function get_sudo_password
{
	local ZENITY_INSTALLED
	local SUDO_PASSWORD2

	is_architech_user
	if [ $? -eq 1 ]
	then
		SUDO_PASSWORD="architech"
		return 0
	fi

	ZENITY_INSTALLED=`dpkg-query -l | grep zenity-common |& awk -F" " '{ print $1 }'`

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
			SUDO_PASSWORD=`zenity --password --title "Please enter sudo password"`
			SUDO_PASSWORD2=`zenity --password --title "Please confirm sudo password"`
		fi
	    done
	else
	    SUDO_PASSWORD="architech"
	fi

	export SUDO_PASSWORD
}

#######################################################################################################################
# execute a command with sudo privileges
# param: $1 string with the command to execute
function do_sudo
{
	local CMD
	CMD=$1
	echo -e ${SUDO_PASSWORD} | sudo -S bash -c "${CMD}"
}

#######################################################################################################################
# message error procedure
# param: $1 error code (ERROR_INTERNET or ERROR_COMMAND)
function message_error
{
	local ERROR_CODE
	ERROR_CODE=$1
	local ERROR_MESSAGE

	case ${ERROR_CODE} in
	${ERROR_INTERNET})
	  ERROR_MESSAGE="Impossible to connect to internet, double check your Internet connection."
	  ;;
	${ERROR_COMMAND})
	  ERROR_MESSAGE="Error in a command, please check log file."
	  ;;
	${ERROR_SPECIFIC})
	  ERROR_MESSAGE=$2
	  ;;
	*)
	  ERROR_MESSAGE="Unknown error, please check log file"
	  ;;
	esac

	echo ${ERROR_MESSAGE}
}



