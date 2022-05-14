#!/bin/bash

excelVar=$( xdotool search --onlyvisible --name excel )
wmctrl -ir $excelVar -b remove,maximized_vert,maximized_horz
xdotool windowsize $excelVar 1888 1016
