#!/bin/bash

echo -n "Say something: "
read STRING
if [[ -z $STRING  ]]; then
	echo "You didn't say anything"
else
	echo Thank for $1
fi

