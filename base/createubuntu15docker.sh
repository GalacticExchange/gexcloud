#!/bin/bash
set -e
rm -rf ubuntu15docker 
mkdir  ubuntu15docker 
vagrant destroy  ubuntu15docker 
vagrant box remove ubuntu15docker | true 
vagrant up ubuntu15docker 
vagrant halt ubuntu15docker |true 
vagrant package ubuntu15docker --output ubuntu15docker/ubuntu15docker.box
vagrant box add --force gex/ubuntu15docker ubuntu15docker/ubuntu15docker.box
