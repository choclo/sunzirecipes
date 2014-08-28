#!/bin/bash
set -e

# Load base utility functions like sunzi.mute() and sunzi.install()
source recipes/sunzi.sh

# This line is necessary for automated provisioning for Debian/Ubuntu.
# Remove if you're not on Debian/Ubuntu.
#export DEBIAN_FRONTEND=noninteractive

# Add Dotdeb repository. Recommended if you're using Debian. See http://www.dotdeb.org/about/
# source recipes/dotdeb.sh
# source recipes/backports.sh

# Update apt catalog and upgrade installed packages
#sunzi.mute "apt-get update"
#sunzi.mute "apt-get -y upgrade"

# Register server against RHN
if subscription-manager version | grep -w 'not registered'; then
  subscription-manager register --username=<%= @attributes.rhn_user %> --password=<%= @attributes.rhn_pass %>
  subscription-manager attach --pool=8a85f9873affb7c1013b199d00832677
  
  # We have to disable all repos that we will not be using:
  yum-config-manager --disable \*

  # Enable basic repo
  yum-config-manager --enable rhel-6-server-rpms

  # Install packages
  yum -y install git ntp curl

else
  echo 'This system is already registered and has repos available'
  yum repolist
fi

# Install sysstat, then configure if this is a new install.
# if sunzi.install "sysstat"; then
#   sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
#   /etc/init.d/sysstat restart
# fi

# Set RAILS_ENV
# environment=<%= @attributes.environment %>

# if ! grep -Fq "RAILS_ENV" ~/.bash_profile; then
#   echo 'Setting up RAILS_ENV...'
#   echo "export RAILS_ENV=$environment" >> ~/.bash_profile
#   source ~/.bash_profile
# fi

# Install Ruby using RVM
# source recipes/rvm.sh
# ruby_version=<%= @attributes.ruby_version %>

# if [[ "$(which ruby)" != /usr/local/rvm/rubies/ruby-$ruby_version* ]]; then
#   echo "Installing ruby-$ruby_version"
#   # Install dependencies using RVM autolibs - see https://blog.engineyard.com/2013/rvm-ruby-2-0
#   rvm install --autolibs=3 $ruby_version
#   rvm $ruby_version --default
#   echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

#   # Install Bundler
#   gem install bundler
#fi