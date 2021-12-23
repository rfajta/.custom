#!/bin/bash

# Sets Logitech K810 function keys as default when connected

## SETUP
##
## 1. As root create /etc/udev/rules.d/50-my_bluetooth_rule.rules with content:
## ACTION=="add", ATTRS{name}=="Logitech K810 Consumer Control", RUN+="/home/robert/bin/onConnect_k810FunctionKeys.sh &"
##
## 2. sudo service udev restart
##
## 3. sudo udevadm control --reload


sleep 1
for deviceNumber in 0 1 2 3 4 5 6 7 ; do
    # logger "Trying device $deviceNumber..." 
    /home/robert/.custom/utils/_k810_conf -f on -d /dev/hidraw${deviceNumber} 2>/dev/null
    if [ $? -eq 0 ]
    then
      # logger "Trying device $deviceNumber was successful" 
      logger "Successfully set keyboard function keys as default"
      exit 0
    fi
    # logger "Trying device $deviceNumber failed" 
done
logger "Failed to set keyboard function keys as default"
