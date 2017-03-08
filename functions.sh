#!/usr/bin/env bash

##############################################
# uptimemon - Simple Service Monitoring
#
# Functions and Variables file
#
# This file does not output anything, rather
# it defines the functions used in the main
# script, and is included at the head of the
# other scripts.
#
# Created by Ben Yanke
# https://github.com/benyanke/uptimemon
##############################################

###### Variables ######

# Current working directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default maxiumum pageload time
defaultAllowableLoadTime="1.0";

# Main Log file
mainLogFile="/var/log/uptimemon/main.log"

# Error Main Log file
errorLogFile="/var/log/uptimemon/error.log"

# Slack auth token
slackAuthToken="xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz"

###### Functions ######

# Master check function
function check() {

  domain=$1;
  maxAllowbleLoadTime=$2;

  # Add checks here
  checkWeb $domain $maxAllowbleLoadTime;


  # Clear variables for later user
  domain="";
  maxAllowbleLoadTime="";
}



# Check the web
function checkWeb() {
  # Error flag
  error=0;

  # Get domain from string
  domain=$1;

  # Get max acceptable load time
  if [[ $2 == "" ]] ; then
    maxAllowableLoadTime=$defaultAllowableLoadTime;
  else
    maxAllowableLoadTime=$2;
  fi

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

  # Check Load time
  loadTimeResult=$(echo $maxAllowableLoadTime'<'$loadTime | bc -l )
  if [[ $loadTimeResult == 1 ]] ; then
    echo "LOAD TIME OVER LIMIT";
    error=1;
  fi

  # Convert curl code
  curlReturnStr=$(curlCodeToString $curlReturn);
  if [[ curlReturn -ne 0 ]] ; then
    error=1;
  fi


  # Output
  out="Domain:         $domain"
  out="$out\n  CURL Status:  $curlReturnStr ($curlReturn)"
  out="$out\n  Load Time:    $loadTime sec"
  out="$out\n\n"

  if [[ $error == 1 ]]; then
    printf "$out";
    logger "$out";
    slackalert "$out";
    return 1;
  fi

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


# convert int curl code to string error
# https://curl.haxx.se/libcurl/c/libcurl-errors.html
function curlCodeToString() {

  errorCode=$1;

  if [[ $errorCode == 0 ]]; then
    echo "Success";

  elif [[ $errorCode == 1 ]]; then
    echo "Unsupported Protocol";

  elif [[ $errorCode == 2 ]]; then
    echo "Failed CURL";

  elif [[ $errorCode == 3 ]]; then
    echo "Not a properly formatted URL";

  elif [[ $errorCode == 4 ]]; then
    echo "Requires a non-installed feature";


  elif [[ $errorCode == 51 ]]; then
    echo "Failed certificate validation";

  else
    echo "Unknown error";

  fi


}


# Logger
function logger() {
  content=$1;

  # add writing to log file here
  touch $mainLogFile
  echo "$content" >> $mainLogFile;

}


# Slack Alert
function slackalert() {
  message=$1;

  curl \
    -X \
    POST -H 'Content-type: application/json' \
    --data "{\"text\":\"uptimemon alert: \n$message\"}" https://hooks.slack.com/services/$slackAuthToken''

}


