#!/bin/bash

# Works in Linux Mint 19 - Cinnamon, Linux Mint 19 - Mate, Ubuntu 18.04 - Gnome

function checkSystem() {
    # Determine if a valid desktop environment is running and exit if it doesn't.
    log "Reported desktop environment: ""$XDG_CURRENT_DESKTOP"
    if [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]; then
        actimeoutid="org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout"
        batttimeoutid="org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout"
        disablevalue=0
    elif [ "$XDG_CURRENT_DESKTOP" = "MATE" ]; then
        actimeoutid="org.mate.power-manager sleep-computer-ac"
        batttimeoutid="org.mate.power-manager sleep-computer-battery"
        disablevalue=0
    elif [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
        actimeoutid="org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type"
        batttimeoutid="org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type"
        disablevalue="nothing"
        systemScreenBrightnessFile="/sys/class/backlight/intel_backlight/brightness"
        dimToBlackValue=0
    else
        log "No valid desktop environment is running"
        exit 1
    fi
}

settingsDir="/home/mu/.config/playback/"
screenBrightnessFile="$settingsDir/screenBrightness"
logFile="$settingsDir/log.txt"

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S  ')""$@" | tee -a $logFile
}

function restoreBrightness() {
    # Restore previous value for screen brightness
    if [ -f $screenBrightnessFile ]; then
        log "  Restoring previous screenBrightness."
        read screenbrightnessval < $screenBrightnessFile 
        echo $screenbrightnessval | sudo /usr/bin/tee $systemScreenBrightnessFile 
    else
        echo 2000 | sudo /usr/bin/tee $systemScreenBrightnessFile
    fi
}

    # Set the suspend timouts to Never using gsettings.
#    log "  Changing suspend timeouts."
#    gsettings set $actimeoutid $disablevalue
#    gsettings set $batttimeoutid $disablevalue
#    log "  Dimming screen to black"
#    echo $dimToBlackValue > $systemScreenBrightnessFile


function main() {
    log "------------------------------------"
    log "$(basename ${0}) started"
    checkSystem

    restoreBrightness
}

main "$@"

