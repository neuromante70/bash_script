#!/bin/bash

if pgrep $1 ; then
	echo $?
	echo $1 is running
fi
