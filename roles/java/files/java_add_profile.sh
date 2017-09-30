#!/usr/bin/env bash

cat >> /etc/profile <<EOT

JAVA_HOME=/usr/local/java/jdk1.8.0_65
PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin
export JAVA_HOME
export PATH

EOT

