#!/bin/bash
for deviceNumber in 0 1 2 3 4 5 6 7 ; do
    sudo ~/bin/_k810_conf -f on -d /dev/hidraw${deviceNumber} 2>/dev/null
    if [ $? -eq 0 ]
    then
      exit 0
    fi
done
echo "Failed to set keyboard"
