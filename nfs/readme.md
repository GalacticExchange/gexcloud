# NFS server in docker

for shared data for servers in gexcloud





# Setup


## NFS server in Docker container

* v1

* https://github.com/ErezHorev/dockerized_nfs_server

* start simple
docker run -d --name mynfs -v /disk3/data/nfs/exports:/exports \
  docker.io/erezhorev/dockerized_nfs_server temp1


* docker network

ip addr show eth0

docker network create -d macvlan --subnet=10.1.0.0/8  --gateway=10.1.0.1  -o parent=eth0 pub_net

# for 10.1.0.31
docker network create -d macvlan --subnet=10.1.0.0/16  --gateway=10.1.0.1  -o parent=enp3s0 pub_net


# static ip
sudo docker run -d --name mynfs --privileged --ip=10.1.0.33 -v /disk2/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server temp1



cd ..
./start.sh temp1

* mount

mkdir -p /disk3/mnt/temp1

sudo umount /disk3/mnt/temp1
sudo mount -v -t nfs -o proto=tcp,port=2049 172.17.0.11:/exports/temp1 /disk3/mnt/temp1
sudo mount -v -t nfs -o proto=tcp,port=2049 51.1.0.50:/disk2/data/gex-main/nfs/exports /disk3/mnt/temp1


* start nfs server in swarm mode

docker service rm nfs

docker service create --replicas 1   --name nfs --network net55 \
  -e constraint:node==mmxpc \
  --restart-delay 10s \
  --restart-max-attempts 3 \
  devgex-nfs


docker service create --replicas 1   --name nfs --network net55 \
  -e constraint:node==mmxpc \
  --restart-delay 10s \
  --restart-max-attempts 3 \
  docker.io/erezhorev/dockerized_nfs_server temp1
  
  
* with mount
  
--mount type=bind,source=/disk3/data/nfs/exports,destination=/exports \
  

docker service create --replicas 1   --name nfs --network net55 \
  -e constraint:node==mmxpc \
  --mount type=bind,source=/disk3/data/temp/t1,destination=/exports \
  docker.io/erezhorev/dockerized_nfs_server


--publish 8080:80   

sudo docker run -d --name mynfs --net=net55 --ip=55.1.0.31 -v /disk2/data/nfs/exports:/exports docker.io/erezhorev/dockerized_nfs_server temp1






# mount from nfs share

51.1.0.50:/disk2/data /disk2/data/gex-main/nfs/exports nfs  auto,noatime,nolock,bg,nfsvers=4,intr,tcp,actimeo=1800 0 0

docker service create --mount type=volume,volume-opt=o=addr=192.168.99.1,volume-opt=device=:/Volumes/HDD/tmp,volume-opt=type=nfs ...


* v1. create volume first
docker volume create --driver local \
    --opt type=nfs \
    --opt o=addr=51.1.0.50,rw \
    --opt device=:/disk2/data/gex-main/nfs/exports \
    --name temp4


* use volume in service

docker service create \
    --name temp2 \
    --mount type=volume,source=temp4,target=/tmp \
    --replicas 1 \
    --restart-delay 10s \
    --restart-max-attempts 3 \
    --constraint 'node.hostname == gexn2' \
    nginx


* volume connected to nfs share directly
a new data volume will be automatically created and connect to nfs share


docker service create \
    --mount type=volume,volume-opt=o=addr=51.1.0.50,volume-opt=device=:/disk2/data/gex-main/nfs/exports,volume-opt=type=nfs,source=temp4,target=/tmp \
    --replicas 1 \
    --name temp4 \
    --restart-delay 10s \
    --restart-max-attempts 3 \
    --constraint 'node.hostname == gexn2' \
    nginx



# v3. from http://collabnix.com/archives/2001

