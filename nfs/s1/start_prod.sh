#!/bin/bash
set -e

#docker run -d --name mynfs --privileged docker.io/erezhorev/dockerized_nfs_server $@
#docker run -d --name mynfs --privileged -p 12049:2049 -v /disk3/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server $@
#sudo docker run -d --name mynfs --privileged -v /disk2/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server temp1

# macvlan
sudo docker run -d --name mynfs --privileged --net=pub_net --ip=10.1.0.32 -v /disk2/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server temp1

# static ip
#sudo docker run -d --name mynfs --privileged --ip=10.1.0.33 -v /disk2/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server temp1


# Source the script to populate MYNFSIP env var
export MYNFSIP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' mynfs)

echo "Nfs Server IP: "$MYNFSIP


# pipework
#sudo /disk2/vagrant/base/common/pipework enp3s0 -i eth1 mynfs  51.77.0.120/9
#sudo /disk2/vagrant/base/common/pipework enp3s0 -i eth1 mynfs  10.1.0.122/16

#docker exec mynfs ip route add 10.1.0.0/16 via 10.1.0.1

#docker exec mynfs ip route add 10.0.0.0/8 via 51.1.1.100
#docker exec mynfs ip route add 51.0.0.0/8 via 51.1.1.100
#docker exec mynfs ip route add 10.0.0.0/8 via 51.1.1.100

