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
readonly ERROR_ABORT=4
readonly ERROR_PASSWORD=5

###########################################################################################################
# Will echo passed parameters only if DEBUG is set to a value. 
# S1 debug message 

function debecho () {
  if [ ${DEBUG_LOG_LEVEL} -gt 0 ]; then
     echo "[DEBUG MESSAGE] $1" >&2
  fi
}

#######################################################################################################################
# return 1 if user is "architech" 0 else
function is_architech_user() {
	[ "${USER}" == "architech" -a "${HOME}" == "/home/architech" ] && { return 1; }
	return 0;
}

#######################################################################################################################
# gets form user the sudo password and exports it
# param optional $1 the password of sudo
function get_sudo_password() {
	local ZENITY_INSTALLED
    local ARG_PWD

    ARG_PWD=${1}

    if [ "${ARG_PWD}" == "" ]
    then
	ZENITY_INSTALLED=`dpkg-query -l | grep zenity-common |& awk -F" " '{ print $1 }'`
	if [ "${ZENITY_INSTALLED}" != "ii" ]
	then
	    echo "Please enter sudo password: "
	    read -s SUDO_PASSWORD
	else
	    SUDO_PASSWORD=`zenity --password --title "Please enter sudo password"`
	fi
    else
        SUDO_PASSWORD=${ARG_PWD}
    fi

    echo -e ${SUDO_PASSWORD} | sudo -p "" -S bash -c "echo"
    [ $? == 0 ] || { password_error; }

    export SUDO_PASSWORD
}

#######################################################################################################################
# Set number of CPU & parallel make.
# param: $1 path where is located "local.conf" file
function set_cpu_localconf() {
	local NR_CPUS
	NR_CPUS=$1
	NR_CPUS=$((NR_CPUS*2))

	sed -i "s|^[ \|\t]*BB_NUMBER_THREADS\(.\)*$||g" $2/local.conf
	echo -e "BB_NUMBER_THREADS = \"${NR_CPUS}\"" >> $2/local.conf

	sed -i "s|^[ \|\t]*PARALLEL_MAKE\(.\)*$||g" $2/local.conf
	echo -e "PARALLEL_MAKE = \"${NR_CPUS}\"" >> $2/local.conf
}

#######################################################################################################################
# execute a command with sudo privileges
# param: $1 string with the command to execute
function do_sudo() {
	local CMD
	CMD=$1

    [ "${SUDO_PASSWORD}" != "" ] || { get_sudo_password; }
	echo -e ${SUDO_PASSWORD} | sudo -p "" -S bash -c "${CMD}"
}

#######################################################################################################################
# message error procedure
# param: $1 error code (ERROR_INTERNET or ERROR_COMMAND)
function message_error() {
	local ZENITY_INSTALLED
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
	    ${ERROR_ABORT})
	      ERROR_MESSAGE="Process aborted. The SDK is in inconsistent state."
	      ;;
	    ${ERROR_PASSWORD})
	      ERROR_MESSAGE="The sudo password is incorrect, process aborted."
	      ;;
	    *)
	      ERROR_MESSAGE="Unknown error, please check log file"
	      ;;
	esac

	ZENITY_INSTALLED=`dpkg-query -l | grep zenity-common |& awk -F" " '{ print $1 }'`

	if [ "${ZENITY_INSTALLED}" != "ii" ]
	then
		echo ${ERROR_MESSAGE}
	else
		zenity --error --text "${ERROR_MESSAGE}"
	fi
}

###########################################################################################################
# Quit functions

function internet_error() {
    message_error ${ERROR_INTERNET}
    exit ${ERROR_INTERNET}
}

function password_error() {
    message_error ${ERROR_PASSWORD}
    exit ${ERROR_PASSWORD}
}

###########################################################################################################
# Trap function

function abort_process() {
    message_error ${ERROR_ABORT}
    exit ${ERROR_ABORT}
}

trap abort_process SIGHUP SIGINT SIGTERM

#######################################################################################################################
# INIT SCRIPT
# -D [0:2] set debug log level [ 0 none, 2 verbose ]; -P [password] insert sudo password

function getparam() {
    DEBUG_LOG_LEVEL=0
    while getopts "D:P:" option
    do
        case ${option} in
        P)
            get_sudo_password ${OPTARG}
        ;;
	    D)
	        DEBUG_LOG_LEVEL=${OPTARG}
	        [ ${DEBUG_LOG_LEVEL} -lt 0 ] && { DEBUG_LOG_LEVEL=0; }
	        [ ${DEBUG_LOG_LEVEL} -gt 2 ] && { DEBUG_LOG_LEVEL=2; }
	    ;;
        esac
    done
}

