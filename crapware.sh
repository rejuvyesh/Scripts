#!/bin/bash

# This script is designed to help you clean your computer from unneeded packages. The script will find all packages that no other installed package depends on. It will output this list of packages excluding any you have placed in the ignore list. You may browse through the script's output and remove any packages you do not need.

# Enter packages and groups here which you know you wish to keep. They will not be included in the list of unrequired packages later.
ignorepkg="firefox skype spotify kgmailnotifier"
ignoregrp="base base-devel"

# Generate usable list of installed packages and packages you wish to keep.
for i in $ignorepkg; do
    ignore="$ignore $i"
done
ignore="$ignore $(pacman -Sg $ignoregrp | awk '{print $2}')"
installed=$(pacman -Qq)

# Check each installed package to see if it is required by anything.
for line in $installed; do
    check=$(pacman -Qi $line | awk '/Required By/ {print $4}')
    if [ "$check" == 'None' ]; then
        match=$(echo $ignore | grep $line)
        
    # Sometimes there may be more than one package containing the search string.
        j=0
        for k in $match; do
            if [ "$k" == "$line" ]; then
	              j=1
            fi
        done
        
    # If package is not required by anything and is not on your list above of packages to ignore, print the package name to the screen.
        if [ "$j" -eq 0 ]; then
            echo $line;
        fi
    fi
done
