#!/bin/bash
set -e 
set -x
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no  ubuntu15docker/ubuntu15docker.box vagrant@files.local:/var/www/html/ubuntu_16_04_gex.box 

