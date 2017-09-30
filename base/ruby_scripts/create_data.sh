#! /bin/bash

source /etc/profile.d/jdk.sh

export ROCANA_HOME=/opt/rocana/rocana-1.4.2
export ROCANA_LIB_DIR=/opt/rocana/rocana-1.4.2/lib
export ROCANA_BIN_DIR=/opt/rocana/rocana-1.4.2/bin
export ROCANA_CONF_DIR=/opt/rocana/rocana-1.4.2/conf
cd ${ROCANA_HOME}
./bin/rocana-data --event-gen --event-size 100 --num-events 10 --num-clients 1


