# This module will initialize the vagrant plugin
require 'nugrant'

module Nugrant
  module Vagrant
    class UserParameters < ::Vagrant::Config::Base
      def initialize()
        @parameters = Nugrant::Parameters.new()
      end

      def [](param_name)
        return @parameters[param_name]
      end

      def method_missing(method, *args, &block)
        return @parameters.method_missing(method, *args, &block)
      end
    end
  end
end

# Plugin bootstrap
Vagrant.config_keys.register(:user) { Nugrant::Vagrant::UserParameters }


