#!/bin/bash

source ./lib.sh


# is_architech_user
USER_TMP=$USER
HOME_TMP=$HOME
is_architech_user
if [ $? -eq 1 ]
then
	echo "error in is_architech_user"
fi
USER="architech"
HOME="/home/architech"
is_architech_user
if [ $? -eq 0 ]
then
	echo "error in is_architech_user"
fi
USER=$USER_TMP
HOME=$HOME_TMP

# get_sudo_password
get_sudo_password
echo "password inserita: ${SUDO_PASSWORD}"

# message_error
message_error ${ERROR_INTERNET}
message_error ${ERROR_COMMAND}
echo "DEBUG_LOG_LEVEL=${DEBUG_LOG_LEVEL}"

# do_sudo
do_sudo "ls -lh"


