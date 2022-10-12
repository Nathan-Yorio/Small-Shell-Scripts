#!/bin/bash

GROUP_NAMES=("ceo" "admins" "managers" "contractors")
MANAGERS=("anthony" "elisa" "jolie" "tom")
ADMINS=("alice" "gabi")
CEO=("bossman")
CONTRACTORS=("contractor")

# make a main company directory
mkdir "/home/OurCompany"

# make a directory for every group
for ((i = 0 ; i < ${#GROUP_NAMES[@]}; i++)); do
	mkdir "/home/OurCompany/${GROUP_NAMES[i]}"
done

# Create the managers, give them their home directory
for ((i = 0 ; i < ${#MANAGERS[@]}; i++)); do
	useradd --password "" --no-user-group --base-dir "/home/OurCompany/${GROUP_NAMES[2]}" --create-home "${MANAGERS[i]}" 
	usermod -aG "${GROUP_NAMES[2]}" "${MANAGERS[i]}"
done

# expire all of the manager's passwords
for ((i = 0 ; i < ${#MANAGERS[@]}; i++)); do
	# Add -S line so I can see who I'm putting in the passwd for
	passwd -S ${MANAGERS[i]}
	passwd -e ${MANAGERS[i]} 
done

# Create the admins, give them their home directory
for ((i = 0 ; i < ${#ADMINS[@]}; i++)); do
	useradd --password "" --no-user-group --base-dir "/home/OurCompany/${GROUP_NAMES[1]}" --create-home "${ADMINS[i]}" 
	usermod -aG "${GROUP_NAMES[1]}" "${ADMINS[i]}"
done

# expire all of the admin's passwords
for ((i = 0 ; i < ${#ADMINS[@]}; i++)); do
	# Add -S line so I can see who I'm putting in the passwd for
	passwd -S ${ADMINS[i]}
	passwd -e ${ADMINS[i]} 
done

# Create the ceo, give him a home directory
useradd --password "" --no-user-group --base-dir "/home/OurCompany/${GROUP_NAMES[0]}" --create-home "${CEO}" 
usermod -aG "${GROUP_NAMES[0]}" "${CEO}"

# expire the ceos password
passwd -S ${CEO}
passwd -e ${CEO} 

# Create the Contractor, give him a home directory
useradd --password "" --no-user-group --base-dir "/home/OurCompany/${GROUP_NAMES[3]}" --create-home "${CONTRACTORS}" 
usermod -aG "${GROUP_NAMES[3]}" "${CONTRACTORS}"

# expire the contractors password
passwd -S ${CONTRACTORS}
passwd -e ${CONTRACTORS} 
