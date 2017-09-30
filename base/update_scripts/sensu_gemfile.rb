#! /usr/bin/env ruby


FRAMEWORK_TEMPLATES = 'https://github.com/GalacticExchange/framework_templates.git'

system('mkdir -p /etc/sensu/')

system("rm -rf /tmp/framework_templates")
system("git clone #{FRAMEWORK_TEMPLATES} /tmp/framework_templates")
system('cp /tmp/framework_templates/node/sensu/Gemfile /etc/sensu')
system('/opt/sensu/embedded/bin/bundle --gemfile=/etc/sensu/Gemfile')

system('/bin/cp -rf /tmp/framework_templates/node/sensu/plugins/* /etc/sensu/plugins/')