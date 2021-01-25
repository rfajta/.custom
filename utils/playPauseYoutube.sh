#!/bin/bash

if [[ "$1" == "0" ]]
then
  keypress="0"
else
  keypress="space"
fi

if xdotool search --all --class --name 'youtube'
then 
  # it is running, send a `space` keystroke to play / pause
  xdotool search --all --class --name 'youtube' key $keypress
else
  # it is not running, start it
  /usr/bin/firefox --class=youtube -P App --no-remote
fi