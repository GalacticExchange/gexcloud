#!/bin/bash
set -e

#docker run -d --name mynfs --privileged docker.io/erezhorev/dockerized_nfs_server $@
#docker run -d --name mynfs --privileged -p 12049:2049 -v /disk3/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server $@
docker run -d --name mynfs --privileged -v /disk3/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server $@

# Source the script to populate MYNFSIP env var
export MYNFSIP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' mynfs)

echo "Nfs Server IP: "$MYNFSIP

# pipework
sudo /projects/gexcloud/base/common/pipework eth0 -i eth1 mynfs  10.1.0.120/16
docker exec mynfs ip route add 10.1.0.0/16 via 10.1.0.1
