#!/bin/bash

sudo apt-add-repository ppa:pipelight/stable
sudo apt-get update
sudo apt-get install pipelight-multi
sudo pipelight-plugin --enable silverlight
sudo pipelight-plugin --enable flash
sudo pipelight-plugin --enable widevine
# sudo pipelight-plugin --enable viewright-caiway
# sudo pipelight-plugin --enable vizzedrgr
