#!/usr/bin/env bash

cd files
vagrant up main &


cd ../socksproxy/
vagrant up main 

cd ../openvpn/
vagrant up main &


cd ../master
vagrant up main &

cd ../dev
vagrant up 
