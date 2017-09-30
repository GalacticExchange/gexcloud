#FROM ubuntu:xenial
FROM phusion/baseimage:0.9.19

# basic tools


# nfs server
RUN apt-get update && apt-get install -y --no-install-recommends \
        netbase \
        nfs-kernel-server \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /exports



# config
#ADD run.sh /usr/local/bin/run.sh
ADD files/exports /etc/exports


# service
RUN  mkdir -p /etc/service/nfs
ADD files/runit.sh /etc/service/nfs/run
RUN chmod +x /etc/service/nfs/run

# restart service
# sv restart flume


# clear
RUN rm -rf /var/lib/apt/lists/*



#
VOLUME /exports

EXPOSE 111/udp 2049/tcp

#ENTRYPOINT ["run.sh"]
