#!/bin/bash

source $HOME/.rvm/scripts/rvm


# install ruby
rvm install 2.2.4


#
rvm use 2.2.4
rvm use 2.2.4 --default
rvm alias create default 2.2.4



# gems
gem install bundler --no-ri --no-rdoc
gem install rake --no-ri --no-rdoc
gem install rails --no-ri --no-rdoc


