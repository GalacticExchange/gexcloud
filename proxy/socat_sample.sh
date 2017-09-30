#!/bin/bash
sudo socat -d -d -lmlocal2 \
TCP4-LISTEN:80,bind=51.1.1.1,su=nobody,fork,reuseaddr \
TCP6:[FD9E:9E:9E:0:0:1:8:0]:80,bind=FD9E:9E:9E:0:0:1:15:0 &
