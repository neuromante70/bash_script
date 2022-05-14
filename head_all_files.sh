#!/bin/bash

for file in *; do
	printf "\n"
	ls $file
	head $file
done
