#!/bin/bash
set -e

#server_ip="10.1.0.12"
#server_port="12049"

server_ip="10.1.0.120"
server_port="2049"

#

mkdir -p /disk3/mnt/temp1

(sudo umount /disk3/mnt/temp1) || true
sudo mount -v -t nfs -o proto=tcp,port=$server_port $server_ip:/exports/temp1 /disk3/mnt/temp1
