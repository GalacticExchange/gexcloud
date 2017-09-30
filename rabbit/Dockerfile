FROM ubuntu:16.04
ENV rabbitmq_admin_user admin
ENV rabbitmq_admin_password PH_GEX_PASSWD1
ENV sensu_admin_user sensu
ENV sensu_admin_password PH_GEX_PASSWD1
ENV sensu_client_user sensu_client
ENV sensu_client_password PH_GEX_PASSWD1

RUN apt-get update



RUN apt-get install -y openssl bashdb  perl make  sudo ruby ruby-full curl logrotate


RUN useradd -p $(openssl passwd -1 vagrant) vagrant

### ufw
RUN apt-get remove -y ufw

RUN gem install slack-notifier

RUN echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list

RUN apt-get install -y wget
RUN wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
RUN apt-key add rabbitmq-signing-key-public.asc
RUN apt-get update && apt-get install --allow-unauthenticated -q -y --force-yes rabbitmq-server=3.6.6-1
RUN service rabbitmq-server start  && rabbitmq-plugins enable rabbitmq_management \
   && /usr/sbin/rabbitmqctl add_vhost /sensu &&  \
   rabbitmqctl add_user $sensu_admin_user $sensu_admin_password && \
   rabbitmqctl set_user_tags $sensu_admin_user administrator && \
    rabbitmqctl set_permissions -p '/sensu' $sensu_admin_user '.*' '.*' '.*' && \
    rabbitmqctl add_user $sensu_client_user $sensu_client_password && \
    rabbitmqctl set_user_tags $sensu_client_user administrator && \
    rabbitmqctl set_permissions -p '/sensu' $sensu_client_user '.*' '.*' '.*' && \
    rabbitmqctl add_user $rabbitmq_admin_user $rabbitmq_admin_password && \
    rabbitmqctl set_user_tags $rabbitmq_admin_user administrator && \
    rabbitmqctl set_permissions -p '/' $rabbitmq_admin_user '.*' '.*' '.*' && \
    rabbitmqctl delete_user guest


# repo

RUN wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -;
RUN echo "deb     http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list;
RUN apt-get update;
RUN apt-get -y --force-yes install sensu=0.21.0-1;
RUN echo "sensu hold" | dpkg --set-selections;
RUN wget https://raw.githubusercontent.com/maxivak/sensu/master/lib/sensu/server/process.rb -O /opt/sensu/embedded/lib/ruby/gems/2.2.0/gems/sensu-0.21.0/lib/sensu/server/process.rb

RUN GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.2.0 /opt/sensu/embedded/bin/gem install \
     sensu-plugin bunny redis pony docker-api net_http_unix sys-proctable

RUN rm /tmp/sensu_* |true

RUN wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -;
RUN echo "deb     http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list;
RUN apt-get update;


RUN apt-get install -y --force-yes uchiwa redis-server


RUN apt-get install --force-yes -y sensu=0.21.0-1
RUN echo "sensu hold" | dpkg --set-selections;
RUN wget https://raw.githubusercontent.com/maxivak/sensu/master/lib/sensu/server/process.rb -O /opt/sensu/embedded/lib/ruby/gems/2.2.0/gems/sensu-0.21.0/lib/sensu/server/process.rb


RUN adduser vagrant sensu

RUN  update-rc.d uchiwa defaults

RUN update-rc.d redis-server defaults

RUN update-rc.d sensu-server defaults
RUN update-rc.d sensu-api defaults


