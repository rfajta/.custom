#!/bin/bash

if pgrep -x "^zoom$" >/dev/null
then
  notify-send "Zoom is killed"
  pkill zoom
else
  zoom "$@" > /dev/null 2>&1 &
  notify-send "Zoom is starting"
fi