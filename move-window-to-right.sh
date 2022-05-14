#!/bin/bash

if [ $1 -eq 2 ]
then
    POS="1280 32"
else
    POS="1280 32"
fi

/usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` $POS

exit 0
