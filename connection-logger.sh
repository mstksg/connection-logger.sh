#!/bin/bash

VERSION="1.0.0"

usage() {
  cat <<-ENDOFUSAGE

  $(basename $0) [period] [host] [timeout]

  Constantly logs the latency of a ping to the given server to stdout, with a
  timestamp.  Useful for monitoring a personal server's connectivity.  CTRL+C
  or kill to quit.

    [period]  Time in seconds betwen the start of each ping.  Defaults to 10.

    [host]    Hostname/IP address over server to ping.  Defaults to 8.8.8.8,
                  Google's DNS nameserver.

    [timeout] The timeout for each ping.  The latency of a timedout ping shows
                  up as "n/a" on the log.  Defaults to 2.

  Written by Justin Le (justin@jle.im) 2013
  Version $VERSION

ENDOFUSAGE
  exit 0
}

while getopts ":h" Option; do
  case $Option in
    h)
      usage
      exit 1;;
  esac
done
shift $(($OPTIND - 1))


PERIOD=${1:-15}             # Delay between pings (seconds)
SERVER=${2:-"8.8.8.8"}      # Server to ping; default: google's DNS nameserver
TIMEOUT=${3:-2}             # Timeout to wait for each ping (seconds)

if [[ $PERIOD -lt $TIMEOUT ]]; then
  TIMEOUT=$PERIOD           # Making sure values are valid.
fi

while [ 1 ]; do
  echo -ne "$(date --rfc-3339="seconds")\t| "

  ping_res=$(ping -W$TIMEOUT -c 1 $SERVER)
  ping_succeed=$(echo "$ping_res" | grep "1 received" | wc -l)
  
  ping_time=$(echo "$ping_res" | grep -o "time=[0-9.]*.*" | grep -o "[0-9.]\+.*")
  ping_time=${ping_time:-"n/a"}

  echo $ping_time

  if [ $ping_succeed ]; then
    sleep $TIMEOUT
  fi


  sleep $(( $PERIOD-$TIMEOUT ))
done
