#!/usr/bin/env bash

cd files
#vagrant up main &


cd ../socksproxy/
#vagrant up dev

cd ../openvpn/
vagrant up dev


cd ../master
#vagrant up dev &

#cd ../api
#vagrant up dev

cd ../rabbit
vagrant up dev


cd ../proxy
vagrant up dev

cd ../webproxy
vagrant up dev
