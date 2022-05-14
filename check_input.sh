#!/bin/bash

echo "Enter the nome of the repository: "
depository_name=""

while [[ ! $depository_name =~ "deb*"$depository_name ]]; do
    echo Please enter your depository: 
    read $depository_name
done
echo You are inserted correct: $depository_name
# touch "$depository_name.list"
