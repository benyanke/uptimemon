#!/usr/bin/env bash

##############################################
# uptimemod - Simple Service Monitoring
#
# Functions and Variables file
#
# This file does not output anything, rather
# it defines the functions used in the main
# script, and is included at the head of the
# other scripts.
#
# Created by Ben Yanke
# https://github.com/benyanke/uptimemond
##############################################

###### Variables ######

# Current working directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###### Functions ######

# Master check function
function check() {
  domain=$1;

  # Add checks here
  checkWeb $domain;

}



# Check the web
function checkWeb() {
  domain=$1;

  # For tracking load time
  before=`timestamp`;

  # Check web
  curl -L -s $domain > /dev/null 2> /dev/null

  curlReturn=$?

  # For tracking load time
  after=`timestamp`;
  # Loadtime in 1/1000 s (ms)
  loadTimeMs=`expr $after - $before`;

  # Calculate loadtime in seconds
  loadTime=$(perl -e "print $loadTimeMs / 1000")

  echo "Domain: $domain"
  echo "CURL Code: $curlReturn"
  echo "Load Time: $loadTime sec"
  echo ""
}


 function checkCertificate() {
  domain=$1;

  echo $domain - certificate not checked

}



timestamp() {
  date +%s%N | cut -b1-13
#  echo $(date +%s)
#  echo $(date +%s%N | cut -b1-13)
}
