#!/bin/bash

echo 'haha'
echo 'haha'

source /etc/profile

echo "AFTER_CREATE" >> /tmp/INIT_LOG

AFTER_CREATE="/after-create"
FIRST_RUN="/etc/first_run.sh"

echo "Executing after create"

if [ -f "$AFTER_CREATE" ]
then
source "${AFTER_CREATE}"
rm "${AFTER_CREATE}"
fi

echo "Executing first run"

echo "FIRST RUN" >> /tmp/INIT_LOG

if [ -f "$FIRST_RUN" ]
then
source "${FIRST_RUN}"
rm "${FIRST_RUN}"
fi

set +x

echo "LOCK_WAIT" >> /tmp/INIT_LOG

while  [  -f /INIT_LOCK ];
do
sleep 0.1
done


set +e

echo "INIT_SH" >> /tmp/INIT_LOG


source /etc/init.sh

while true
do
    sleep 1000
done
