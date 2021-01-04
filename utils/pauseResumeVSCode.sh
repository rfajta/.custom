#!/bin/bash

if ps -ax -o pid,user,cmd,state | grep '/usr/share/code/code ' | grep -q " T$" 
then
    pkill -CONT code
    notify-send "VSCode is now active"
else
    pkill -STOP code
    notify-send "VSCode is now paused"
fi
