FROM ubuntu:16.04

RUN apt-get update

RUN  apt-get install -y socat openssl  openssh-server openssh-client vim nano curl ruby-full sudo \
                                    net-tools htop iputils-ping make patch build-essential  perl logrotate

RUN useradd -p $(openssl passwd -1 vagrant) vagrant

RUN useradd -p $(openssl passwd -1 887218924) socks_user

RUN apt-get remove -y ufw


RUN  gem  install pry pry-byebug zookeeper slack-notifier diplomat

# https://github.com/weheartwebsites/SOCKS5/wiki/Install-a-SOCKS5-server-(Dante)-on-Debian-Wheezy
# install Dante
RUN \
        wget -O /usr/src/dante-1.4.1.tar.gz https://www.inet.no/dante/files/dante-1.4.1.tar.gz && \
        cd /usr/src && \
        tar xvfz dante-1.4.1.tar.gz && \
        cd dante-1.4.1 && \
        ./configure && \
        make && \
        make install
