#!/bin/bash

a=$(sed 's/ /_/g' <<< $1)
touch $a
