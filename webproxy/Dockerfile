FROM ubuntu:16.04

RUN apt-get update

RUN apt-get remove -y ufw

RUN apt-get install -y --force-yes python-keyczar nodejs npm

RUN apt-get install -y  openssl bashdb  perl make  autofs sudo ruby ruby-full curl libpcre3 libpcre3-dev iputils-ping \
   logrotate

#libreadlinedev libncurses5dev libpcre3dev buildessential libssldev

RUN useradd -p $(openssl passwd -1 vagrant) vagrant

RUN  /usr/bin/gem install zookeeper slack-notifier

RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -

RUN npm install jsonwebtoken

RUN mkdir -p /home/vagrant/temp && chown vagrant:vagrant /home/vagrant && chown vagrant:vagrant /home/vagrant/temp  && \
     chmod 0755  /home/vagrant && chmod  0700 /home/vagrant/temp

ENV TARGET /home/vagrant/temp/ngx_openresty-1.7.10.2.tar.gz

ADD   http://openresty.org/download/ngx_openresty-1.7.10.2.tar.gz $TARGET
RUN   chown vagrant:vagrant $TARGET && chmod 0755 $TARGET
RUN   cd /home/vagrant/temp && tar xzvf ngx_openresty-1.7.10.2.tar.gz

ENV   TARGET /home/vagrant/temp/openssl-1.0.2e.tar.gz
ADD   http://www.openssl.org/source/old/1.0.2/openssl-1.0.2e.tar.gz  $TARGET
RUN   chown vagrant:vagrant $TARGET && chmod 0755 $TARGET



RUN  cd /home/vagrant/temp/ngx_openresty-1.7.10.2 && ./configure --prefix=/opt/openresty --with-luajit --with-pcre-jit --with-ipv6 --with-http_ssl_module
RUN  cd /home/vagrant/temp/ngx_openresty-1.7.10.2  && make && make install


ENV   TARGET /home/vagrant/nginx-jwt.tar.gz
ADD   https://github.com/auth0/nginx-jwt/releases/download/v1.0.1/nginx-jwt.tar.gz $TARGET
RUN   chown vagrant:vagrant $TARGET && chmod 0755 $TARGET

RUN   cd /home/vagrant &&  tar xvf nginx-jwt.tar.gz

RUN   cd /home/vagrant/temp && tar vxf openssl-1.0.2e.tar.gz

#ENV   TARGET /home/vagrant/temp/nginx-jwt-sources.tar.gz
#ADD   http://files.gex/bin/openresty/nginx-jwt-sources-1.0.1.tar.gz $TARGET
#RUN   chown vagrant:vagrant $TARGET && chmod 0755 $TARGET
#RUN   cd=/home/vagrant/temp &&  tar -zxvf nginx-jwt-sources.tar.gz
#RUN   chdir=/home/vagrant/temp &&  mv nginx-jwt-1.0.1 nginx-jwt-sources
