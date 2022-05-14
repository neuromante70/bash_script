#!/bin/bash

for file in *_*
do 
        echo mv $file $( sed 's/\(.*\)_/\1\./' <<< $file)
done
