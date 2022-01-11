#!/bin/bash
function green { echo -e "\e[32m$*\e[39m"; }
function red { echo -e "\e[31m$*\e[39m"; }
export $(grep -v '^#' .env | xargs -d '\n')

if [ -z "$printerip" ]; then
    green "Enter Printer IP Address: "
    read printerip
fi

green "Enter the ammount of time you want the timelapse to run for: "
read printtime
green "Enter the ammount of time between images: "
read interval
green "Enter the print name (folder will be created): "
read printname
mkdir $printname 2>/dev/null

est_time=$(date -d "$printtime" "+%s")
green "Starting at: $(date)"
red "Ending at: $(date -d "$printtime")"
green "Enter starting image number: "
read num
green "Starting capture at: $(date) on $printerip"
green "Press enter to start capture"
read
while [ $(date "+%s") -lt ${est_time} ]; do
    green "Capturing image: $num"
    ffmpeg -i http://$printerip:8080/?action=stream -f image2 -frames:v 1 ${printname}/${printname}-${num}.png 1> /dev/null
    green "Finished capturing image: $num"
    green "Time remaining: $(date -d @$(($est_time - $(date "+%s"))) +%H:%M:%S)"
    green "Next capture in $interval seconds"
    sleep ${interval}
    num=$((num+1))
done
green "Finished at: $(date)"