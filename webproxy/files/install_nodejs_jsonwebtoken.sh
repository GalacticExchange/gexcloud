#!/usr/bin/env bash

curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -

sudo apt-get install -y --force-yes nodejs
sudo apt-get install -y --force-yes npm


npm install jsonwebtoken
