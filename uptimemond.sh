#!/usr/bin/env bash

##############################################
# uptimemod - Simple Service Monitoring
#
# Main File - Run this file to run tests
#
# Created by Ben Yanke
# https://github.com/benyanke/uptimemond
##############################################

# Get Current Directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include functions file
source $DIR/functions.sh


# Add sites here to monitor
# check "domain"

check "null.publicserver.xyz"
check "www.romancatholicman.com"
check "www.stmarypb.com"

