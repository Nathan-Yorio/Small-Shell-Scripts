#!/bin/bash

#dirname grabs the directory path name ignoring trailing slashes
#stackoverflow explanation of the use of array BASH_SOURCE[0] vs BASH_SOURCE
#https://stackoverflow.com/questions/35006457/choosing-between-0-and-bash-source
#Basically I saw some other script use the [0] and I wanted to know why and 
#apparently it's not actually needed at all
echo
echo


#BASH_SOURCE to get the current directory to find the config file
current_directory=$(cd $(dirname "${BASH_SOURCE}") && pwd)
echo "Current directory is ${GREEN}${current_directory}${NOCOLOR}"

#Identify location of config file
config_file="${current_directory}/variables.conf" 
echo "Config file is ${GREEN}${config_file}${NOCOLOR}"

# Read in the config file's variables and print them out for my sanity and for debugging
source "$config_file" || exit 1
echo -e "Cloud provider name is       : ${BLUE}${rcloneCloudProviderName}${NOCOLOR}"
echo -e "Cloud provider directory is  : ${BLUE}${rcloneCloudProviderDir}${NOCOLOR}"
echo -e "Directory to be backup up is : ${BLUE}${BackupDir}${NOCOLOR}"
echo 

# Rclone to Cloud Provider
##################################################################################
echo "$(date +"%H:%M:%S"): Performing Rclone Backup of Folder to Cloud Provider..."
echo -e "${LPURPLE}"
rclone sync -vv ${BackupDir} ${rcloneCloudProviderName}:${rcloneCloudProviderDir}
echo -e "${NOCOLOR}"
echo "Done"
echo
###################################################################################