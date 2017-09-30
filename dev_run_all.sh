#!/usr/bin/env bash

cd files
vagrant up devfiles

cd ../rabbit/
vagrant up devrabbit

cd ../proxy/
vagrant up devproxy

cd ../webproxy/
vagrant up devwebproxy

cd ../openvpn/
vagrant up devopenvpn
