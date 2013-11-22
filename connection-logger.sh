#!/bin/bash

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
