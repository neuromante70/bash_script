#!/bin/bash

if [[ `echo $HOSTNAME | awk -F "localhost." ' { print $2 } '` = $1 ]]; then
	echo You are on your home machine
else
	echo You must be somewhere else 
fi
