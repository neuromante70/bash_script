#!/bin/bash

rpm -qa --qf '%{NAME} %{VENDOR}\n' | grep -v CentOS
