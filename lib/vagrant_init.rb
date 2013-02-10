# This module will initialize the vagrant plugin
require 'nugrant/vagrant/command/root'
require 'nugrant/vagrant/config/user'

# Plugin bootstrap
Vagrant.commands.register(:user) { Nugrant::Vagrant::Command::Root }
Vagrant.config_keys.register(:user) { Nugrant::Vagrant::Config::User }
