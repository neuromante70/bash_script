#!/bin/bash

## Disable touchpad if USB Mouse is attached

SYNAPTICS=`which synclient`

if [[ "$SYNAPTICS" == "" ]]
then
    echo "$0: please install synaptics touchpad driver."
    echo "Also make sure that 'Option         \"SHMConfig\" \"on\"'"
    echo " is added in Touchpad device Section in /etc/X11/xorg.conf"
    exit
fi

USB_mouse_present=`grep -ic "usb.*mouse" /proc/bus/input/devices`
# if no USB Mouse; enable touchpad
if [ $USB_mouse_present -eq 0 ]
then
    $SYNAPTICS TouchpadOff=0
else
    $SYNAPTICS TouchpadOff=1
fi 

# if any parameter [on|off] is given, override previous command
if [ $# -ge 1 ]
then
    if [ "$1" = "on" ]
    then
        $SYNAPTICS TouchpadOff=0
    else
        $SYNAPTICS TouchpadOff=1
    fi
fi

exit 0
