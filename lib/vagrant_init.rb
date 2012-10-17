# This file is automatically loaded by Vagrant.
require 'nugrant'

# Some Vagrant-specific stuff here
puts "Loading plugin"

Vagrant.config_keys.register(:nuecho) { "value" }
