#!/bin/bash


pip show powerline-status


pip show powerline-status  | grep "^Location: " | cut -d ":" -f 2 
