#!/bin/bash

if [ "$#" = "1" ]
then 
	find "." -type f -printf '%p %s\n' | grep -i $1
else
	find $1 -type f -printf '%p %s\n' | grep -i $2
fi

