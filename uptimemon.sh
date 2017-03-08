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


# Add sites here to monitor
# check "domain"

check "www.romancatholicman.com"
check "www.stmarypb.com"
check "angeluspress.org" 7
check "www.angelusonline.org" 7
check "knightsofdivinemercy.com"
check "www.latinmassmadison.org"
check "null.publicserver.xyz"
