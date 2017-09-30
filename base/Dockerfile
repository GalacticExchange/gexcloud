# Creates pseudo distributed hadoop 2.6.0 on Ubuntu 14.04
#
# docker build -t sequenceiq/hadoop-ubuntu:2.6.0 .

FROM gex/base

MAINTAINER Gex

USER root


#RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh 

CMD ["/etc/bootstrap.sh", "-d"]

#RUN $BOOTSTRAP

ENTRYPOINT ["/etc/bootstrap.sh"]

