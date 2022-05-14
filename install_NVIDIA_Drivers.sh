#!/bin/bash

~$ sudo add-apt-repository ppa:xorg-edgers
~$ sudo apt-get update
~$ sudo apt-get install nvidia-331
~$ sudo nvidia-xconfig
~$ sudo shutdown -r now
