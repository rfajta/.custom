#!/bin/bash

playerCommand=$1
if ! pgrep -x audacious > /dev/null
then
  audacious &
  sleep 0.5
fi


if [[ ! -z $1 ]]
then
  playerctl -p audacious $1
fi
