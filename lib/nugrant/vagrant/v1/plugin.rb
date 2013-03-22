require 'nugrant/vagrant/v1/command/root'
require 'nugrant/vagrant/v1/config/user'

# Plugin bootstrap
Vagrant.commands.register(:user) { Nugrant::Vagrant::V1::Command::Root }
Vagrant.config_keys.register(:user) { Nugrant::Vagrant::V1::Config::User }
