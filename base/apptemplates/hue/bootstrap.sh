#!/bin/bash

AFTER_CREATE="/after-create"
FIRST_RUN="/etc/first_run.sh"
if [ -f "$AFTER_CREATE" ]
then
source "${AFTER_CREATE}"
rm "${AFTER_CREATE}"
fi

if [ -f "$FIRST_RUN" ]
then
source "${FIRST_RUN}"
fi

source /etc/init.sh

while true
do
sleep 1000
done



