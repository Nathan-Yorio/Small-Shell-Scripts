#!/bin/bash

#BASH_SOURCE to get the current directory to find the config file
current_directory=$(cd $(dirname "${BASH_SOURCE}") && pwd)
echo "Current directory is ${GREEN}${current_directory}${NOCOLOR}"

#Identify location of config file
config_file="${current_directory}/variables.conf" 
echo "Config file is ${GREEN}${config_file}${NOCOLOR}"

# Read in the config file's variables and print them out for my sanity and for debugging
source "$config_file" || exit 1

#figure out later why a space gets put on the pretty array echo line?
for ((i = 0 ; i <= 4 ; i++)); do
#	pretty_array=$($(echo ${COLORS[i]}) + $(echo ${i}) + $(echo ${NOCOLOR}))
	pretty_array=""${COLORS[i]}" "${DAYS[i]}" "${NOCOLOR}""
	echo "${i}"
	echo -e "${pretty_array}"
done