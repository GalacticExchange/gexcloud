#!/bin/sh
sudo rm -rf /etc/systemd/system/hm*
sudo rm -rf /etc/systemd/system/hue*
sudo systemctl daemon-reload
sudo docker rm -f $(sudo docker ps -q -a)

