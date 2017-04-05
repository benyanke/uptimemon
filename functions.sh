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
defaultAllowableLoadTime="10.0";
defaultAllowableLoadTime="40.0";
# defaultAllowableLoadTime="0.001"; ## Handy when you want to trigger all alerts

# Backoff and repeat time
# If there is a failure, wait this many seconds before retrying to confirm outage
backoffTime="10";
# backoffTime="1";

# Repeat before alert
# If there is a failure, repeat test this many times before alerting to failure
failureRepeat="3";


# Sleep Between Checks
sleepBetweenChecks=10;

# Main Log file
mainLogFile="/var/log/uptimemon/main.log"

# Error Main Log file
errorLogFile="/var/log/uptimemon/error.log"

# Slack api keys
# slackAuthToken="xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz"
slackAuthToken="$(cat $DIR/slack.token)";


# Twilio api keys
twilio_sid="$(cat $DIR/twilio_sid.token)";
twilio_auth="$(cat $DIR/twilio_auth.token)";
twilio_to="$(cat $DIR/twilio_to.token)";
twilio_from="$(cat $DIR/twilio_from.token)";


###### Functions ######

# Master check function
function check() {

  domain=$1;
  maxAllowbleLoadTime=$2;

  # Add checks here
  checkWeb $domain $maxAllowbleLoadTime &
  sleep $sleepBetweenChecks

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

  # The current check count
  if [[ $3 == "" ]] ; then
#    echo "default: 1 ($3)"
    checkNum=1;
  else
    checkNum=$3;
#    echo "override: $checkNum"
  fi


#  echo "Start DEBUG: $domain $maxAllowableLoadTime $checkNum";


  # For tracking load time
  before=`timestamp`;

  # Check web
  curl --retry $failureRepeat --retry-delay $backoffTime --fail -L -s $domain > /dev/null 2> /dev/null
#  curl --fail -L -s $domain > /dev/null 2> /dev/null

  curlReturn=$?

  # For tracking load time
  after=`timestamp`;
  # Loadtime in 1/1000 s (ms)
  loadTimeMs=`expr $after - $before`;

  # Calculate loadtime in seconds
  loadTime=$(perl -e "print $loadTimeMs / 1000")

  out="\nDomain:         $domain"


  # Check Load time
  loadTimeResult=$(echo $maxAllowableLoadTime'<'$loadTime | bc -l )
  if [[ $loadTimeResult == 1 ]] ; then
    out="$out\nLoad Time:     $loadTime sec"
    error=1;
  fi

  # Convert curl code
  curlReturnStr=$(curlCodeToString $curlReturn);
  if [[ curlReturn -ne 0 ]] ; then
    out="$out\nHTTP Status:   $curlReturnStr"
    error=1;
  fi

   printf "$out";
#  echo "end of main test segment $domain";

  if [[ $error == 1 ]]; then

#    echo "Error state";

#    checkNum=$(eval "$failureRepeat + 1");

#    if [[ $checkNum -le $failureRepeat ]] ; then

#      echo "error $checkNum";

#      checkNum=$(expr $checkNum + 1);
 
#      echo "error $checkNum";

#      sleep $backoffTime;
#      echo "$domain $maxAllowableLoadTime $checkNum";
#      check $domain $maxAllowableLoadTime $checkNum;

#    else

#      echo "sending alert - error $checkNum";

      out="$out\n\n"

      printf "$out";
      logger "$out";
      slackalert "$out";
      twilioalert "$out";
      return 1;

#    fi

#    else 

#      echo "No error found on $domain"

  fi

}


 function checkCertificate() {
  domain=$1;

  echo $domain - certificate not checked

}


# Returns unix timestamp in 1/1000 of a
# second for timing purposes
timestamp() {
  date +%s%N | cut -b1-13
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
    echo "Unspecified CURL error";

  elif [[ $errorCode == 3 ]]; then
    echo "Not a properly formatted URL";

  elif [[ $errorCode == 4 ]]; then
    echo "Requires a non-installed feature";

  elif [[ $errorCode == 5 ]]; then
    echo "Could not resolve proxy";

  elif [[ $errorCode == 6 ]]; then
    echo "Could not resolve host";

  elif [[ $errorCode == 7 ]]; then
    echo "Could not connect";

  elif [[ $errorCode == 16 ]]; then
    echo "HTTP2 framing layer issue";

  elif [[ $errorCode == 22 ]]; then
    echo "HTTP Error";

  elif [[ $errorCode == 51 ]]; then
    echo "Failed certificate validation";

  elif [[ $errorCode == 60 ]]; then
    echo "TLS Certificate could not be verified";

  else
    echo "Unknown error: CURL code #$errorCode";

  fi

}


# Logger
function logger() {
  content=$1;

  # add writing to log file here
  touch $mainLogFile
  printf "$content" >> $mainLogFile;

}


# Slack Alert
function slackalert() {
  message=$1;

  curl \
    -X \
    POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$message\"}" https://hooks.slack.com/services/$slackAuthToken'' >/dev/null 2>&1

  # Add notification here to check curl's return status

}

# Twilio Alert
function twilioalert() {

  message=$1;
#  message="$(echo "$message" | sed -r 's/\\n+/%0a/g')";
  message="$(echo "$message" | sed -r 's/\\n+/ /g')";
  message="$(echo "$message"  | sed -r 's/  / /g' | sed -r 's/  / /g' | sed -r 's/  / /g' | sed -r 's/  / /g' | sed -r 's/  / /g')";

  curl -X POST -F "Body=Uptimemon: $message" \
    -F "From=${twilio_from}" -F "To={$twilio_to}" \
    "https://api.twilio.com/2010-04-01/Accounts/${twilio_sid}/Messages" \
    -u "${twilio_sid}:${twilio_auth}" >/dev/null 2>&1

  # Add notification here to check curl's return status

}

# Lock functions

function isLocked() {
        if [ -e /tmp/sitescanlock ] ; then
		return 0;
	else
		return 1;
	fi
}

function exitIfLocked() {
	isLocked && echo "Exiting due to already-running" && exit;
}

function createLock() {
	echo "Creating lock";
	echo $(date +%s) > /tmp/sitescanlock 2>/dev/null
}

function clearLock() {
	echo "Clearing lock";
	rm /tmp/sitescanlock >/dev/null 2>&1
}

