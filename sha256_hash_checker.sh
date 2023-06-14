#!/bin/bash
# Stolen and modified from https://github.com/dragoonDorise/EmuDeck/blob/main/functions/checkBIOS.sh
# This one's originally checking a folder for some bios files but I wanted a little modular script
# that can cryptographically validate some hashes that are more secure than md5sums and not susceptible to collisions (yet)

# pre-declare some variables
filePath=.
VALID_FILES=()

sha256HashCheck(){
	FILE_FOUND="NULL"                                     # Files haven't yet been found
	for entry in "$filePath/"*
	do
		if [ -f "$entry" ]; then 		                 		    # check if there's even an entry there
			sha256=($(sha256sum "$entry"))	            			# This piece takes the sha256 sum of the current file
			# Then here's an array of all of the possible sha256sums of the file(s) we want to find in this folder
			FILECheck=(66678137a1964147efca4eccca3bd982dd991b388390a7668963be218da5204a 002aa774323d2e686f53b282f3ad539092ba477228f7f253bf78130b17345311)
			# This little gem says "expand out the array into individual elements and iterate in a for loop"
			for i in "${FILECheck[@]}"; do
				if [[ "$sha256" == *"${i}"* ]]; then
					VALID_FILES+=("$entry")
					FILE_FOUND=true
				else
					if [[ "$FILE_FOUND" != true ]]; then
						FILE_FOUND=false
					fi
				fi
			done
		fi
	done

	if [ $FILE_FOUND == true ]; then
		echo "Valid File Found";
	else
		echo "No Valid File Found";
	fi

	for i in "${VALID_FILES[@]}"; do
		echo "$i"
	done
}

# Run it
sha256HashCheck "$@"
