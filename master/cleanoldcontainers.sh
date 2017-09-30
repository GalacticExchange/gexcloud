#!/bin/sh
sudo rm -rf /etc/systemd/system/hm*
sudo rm -rf /etc/systemd/system/hue*
sudo systemctl daemon-reload
sudo docker stop -t 1 $(sudo docker ps -q -a --filter "before=$1" )
sudo docker rm $(sudo docker ps -q -a)

