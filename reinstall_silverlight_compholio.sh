#!/bin/bash
# echo 'deb http://www.yourdomain.com/packages/ubuntu /' >> /etc/apt/sources.list.d/yourdomain.sources.list

rm -rf ~/.wine-pipelight/
sudo apt-get remove -y pipelight
sudo apt-get install -y pipelight pipelight-multi 
sudo pipelight-plugin--enable silverlight
netflix
