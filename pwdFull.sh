#!/bin/bash

if test $(pwd -L) = $(pwd -P); then
    pwd
else
    printf "`pwd -L` -->  `pwd -P`\n"
fi

