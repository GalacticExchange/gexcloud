#!/bin/bash

# install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

\curl -sSL https://get.rvm.io | bash -s stable



# source

# >> .bash_profile
echo "source $HOME/.rvm/scripts/rvm" >> ~/.bash_profile

# >> .bashrc
echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
#source $HOME/.rvm/scripts/rvm


#
source $HOME/.rvm/scripts/rvm
