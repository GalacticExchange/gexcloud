#!/bin/sh
sudo rm -rf /etc/systemd/system/hadoop-master-$1.service 
sudo rm -rf /etc/systemd/system/hue-master-$1.service
sudo systemctl daemon-reload
sudo docker stop   hadoop-master-$1 
sudo docker stop  hue-master-$1
sudo docker rm hadoop-master-$1 
sudo docker rm hue-master-$1

