#!/bin/bash
for deviceNumber in 0 1 2 3 4 5 6 7 ; do
    sudo ~/bin/_k810_conf -f on -d /dev/hidraw${deviceNumber}
done
