#!/bin/bash

echo 10000 > /proc/sys/user/max_user_namespaces
echo $?
