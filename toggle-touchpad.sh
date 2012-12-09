#!/bin/bash
#Toggles the touchpad
if [ $(synclient -l | grep TouchpadOff | awk '{print $3}') == 1 ] ; then
    synclient touchpadoff=0;
else
    synclient touchpadoff=1; #Turn off the touchpad
fi
