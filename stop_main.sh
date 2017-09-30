#!/usr/bin/env bash

cd files
vagrant halt main 

cd ../rabbit/
vagrant halt main 

cd ../socksproxy/
vagrant halt main 

cd ../openvpn/
vagrant halt main 

cd ../master
vagrant halt main 
