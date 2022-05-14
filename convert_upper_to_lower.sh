#!/bin/bash

touch $(echo $1 | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]').sh
