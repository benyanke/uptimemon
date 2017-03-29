#!/usr/bin/env bash

##############################################
# uptimemon - Simple Service Monitoring
#
# Main File - Run this file to run tests
#
# Created by Ben Yanke
# https://github.com/benyanke/uptimemon
##############################################

# Get Current Directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include functions file
source $DIR/functions.sh

# Run clearLock on script exit
# trap clearLock EXIT # Gotta fix this in a more robust way

# Exiting if already running - don't allow to run concurrently!
exitIfLocked;

# Creating lock file
createLock;

for site in $(cat $DIR/domains.list) ; do
	check "$site"
done

# Clearing lock file
clearLock;
