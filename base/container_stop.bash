#!/usr/bin/env bash

/usr/bin/docker exec -t $1 ip link del eth1

/usr/bin/docker stop -t 5 $1

