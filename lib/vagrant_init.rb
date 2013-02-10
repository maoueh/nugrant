# This module will initialize the vagrant plugin
require 'nugrant/vagrant/user_command'
require 'nugrant/vagrant/config/user'

# Plugin bootstrap
Vagrant.commands.register(:user) { Nugrant::Vagrant::UserCommand }
Vagrant.config_keys.register(:user) { Nugrant::Vagrant::Config::User }
