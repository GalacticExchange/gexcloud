FROM ubuntu:16.04

RUN apt-get update

RUN  apt-get install -y openvpn zookeeper avahi-daemon dnsmasq openssl autofs openssh-server openssh-client vim nano curl ruby-full sudo \
     net-tools htop patch build-essential  perl make iputils-ping logrotate dnsutils

RUN useradd -p $(openssl passwd -1 vagrant) -m -s /bin/bash vagrant
RUN echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# remove
RUN  apt-get remove -y ufw


RUN sed -i 's/#except-interface=/except-interface=eth0/g' /etc/dnsmasq.conf

RUN  gem install json zookeeper slack-notifier chef diplomat

#RUN mkdir /tmp/consul; cd /tmp/consul; wget https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_linux_amd64.zip && \
#RUN cd /tmp/consul; wget https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_web_ui.zip
#RUN cd /tmp/consul && unzip *amd64.zip && unzip *ui.zip && rm *.zip
#RUN mv /tmp/consul/consul /usr/bin && mv /tmp/consul /usr/bin/consul-ui

RUN unzip consul/consul.zip -d /tmp/
RUN cp /tmp/consul /usr/bin/


RUN mkdir /etc/consul

