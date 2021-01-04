#!/bin/bash

# Works in Linux Mint 19 - Cinnamon, Linux Mint 19 - Mate, Ubuntu 18.04 - Gnome

# Script to temporarily set suspend timout for AC and battery to "Never"
# while audio is playing.  It then reverts the settings when audio is no longer detected.


function checkSystem() {
    # Determine if a valid desktop environment is running and exit if it doesn't.
    log "Reported desktop environment: $XDG_CURRENT_DESKTOP"
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
    screenSize=$(xdpyinfo | grep -m1 dimensions | awk '{print $2}')
    log "Screen size: $screenSize"
}

settingsDir="/home/mu/.config/playback/"
acSuspendFile="$settingsDir/acSuspend"
battSuspendFile="$settingsDir/battSuspend"
screenBrightnessFile="$settingsDir/screenBrightness"
logFile="$settingsDir/log.txt"
logClearThreshold=10000000
sleepTime="5s"

playbackNothing="N"
playbackMusic="M"
playbackFullscreen="V"

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S  ')""$@" | tee -a "$logFile"
}

getActiveWindowSize() {
    echo $(xwininfo -id $(xdotool getactivewindow) -stats | \
        egrep '(Width|Height):' | \
        awk '{print $NF}') | \
    sed -e 's/ /x/'
}

clearLogFileIfNeeded() {
    if [[ $(stat --printf="%s" "$logFile") -gt $logClearThreshold ]] ; then 
        echo > $logFile
        log "Log file cleared because it exceeded $logClearThreshold bytes" 
    fi
}

function dimOffAndRestore() {
    # Restore previous value for screen brightness and delete the
    # temporary file storing it.
    if [[ -f $screenBrightnessFile ]]; then
        log "  Restoring previous screenBrightness."
        read screenbrightnessval < $screenBrightnessFile 
        echo $screenbrightnessval | sudo /usr/bin/tee $systemScreenBrightnessFile 
        log "  Removing temporary file $screenBrightnessFile "
        rm $screenBrightnessFile 
    fi
}

function suspendOnAndRestore() {
    # Restore previous value for AC suspend timeout and delete the
    # temporary file storing it.
    if [[ -f $acSuspendFile ]]; then
        log "  Restoring previous AC suspend timeout."
        read acsuspendtime < $acSuspendFile
        gsettings set $actimeoutid $acsuspendtime
        log "  Removing temporary file $acSuspendFile"
        rm $acSuspendFile
    fi

    # Restore previous value for battery suspend timeout and delete the
    # temporary file storing it.
    if [[ -f $battSuspendFile ]]; then
        log "  Restoring previous battery suspend timeout."
        read battsuspendtime < $battSuspendFile
        gsettings set $batttimeoutid $battsuspendtime
        log "  Removing temporary file $battSuspendFile"
        rm $battSuspendFile
    fi
}

function dimOnAndSave() {
        # If screen brightness was not previously saved, then save it.
    if [[ ! -f $screenBrightnessFile ]]; then
        log "  Saving current screen brightness."
        cp $systemScreenBrightnessFile $screenBrightnessFile 
        log "  Dimming screen to black"
        echo $dimToBlackValue | sudo /usr/bin/tee $systemScreenBrightnessFile
    fi
}

function suspendOffAndSave() {
    # If AC timeout was not previously saved, then save it.
    if [[ ! -f $acSuspendFile ]]; then
        log "  Saving current AC suspend timeout."
        gsettings get $actimeoutid > $acSuspendFile
        log "  Disabling AC suspend timeouts."
        gsettings set $actimeoutid $disablevalue
    fi

    # If battery timeout was not previously saved, then save it.
    if [[ ! -f $battSuspendFile ]]; then
        log "  Saving current battery suspend timeout."
        gsettings get $batttimeoutid > $battSuspendFile
        log "  Disabling battery suspend timeouts."
        gsettings set $batttimeoutid $disablevalue
    fi

}


function cleanupAndExit() {
    log "SCRIPT INTERRUPTED"
    suspendOnAndRestore
    dimOffAndRestore
    log "EXITING"
    log "------------------------------------"
    exit 0
}

function main() {
    log "------------------------------------"
    log "$(basename ${0}) started"
    checkSystem
    trap 'cleanupAndExit' EXIT SIGINT SIGKILL SIGTERM SIGSTOP SIGABRT

    # Restore previous value for AC suspend timeout if script
    # was interrupted.
    suspendOnAndRestore
    dimOffAndRestore
    # sleepTime="5s"
    windowSize=""
    playbackStatus="$playbackNothing"
    # Start main loop to check if audio / fullscreen video is playing
    while true; do
        clearLogFileIfNeeded
        log "playbackStatus: $playbackStatus"
        # Are there any running audio sources?
        if pactl list | grep -B 1 "State: RUNNING" | grep -q "Sink #" ; then
            prevWindowSize=$windowSize
            windowSize=$(getActiveWindowSize)
            # Is fullscreen video running?
            if [[ "$screenSize" == "$windowSize" ]]; then
                if [[ "$playbackStatus" != "$playbackFullscreen" || "$windowSize" != "$prevWindowSize" ]] ; then
                    log "Video playback in full screen detected"
                    suspendOffAndSave
                    dimOnAndSave
                    playbackStatus="$playbackFullscreen"
                fi
            else
                if [[ "$playbackStatus" != "$playbackMusic"  || "$windowSize" != "$prevWindowSize" ]] ; then
                    log "Music playback detected"
                    suspendOffAndSave
                    dimOffAndRestore
                    playbackStatus="$playbackMusic"
                fi
            fi
            # sleepTime="5s"
        else
            if [[ "$playbackStatus" != "$playbackNothing" ]]
            then
                log "No playback detected"
                suspendOnAndRestore
                dimOffAndRestore
                # sleepTime="5s"
                playbackStatus="$playbackNothing"
            fi
        fi

        # Pause the script for 60 seconds before doing the loop again.
        log "Rechecking in $sleepTime seconds."
        sleep $sleepTime

    done
}

main "$@"

