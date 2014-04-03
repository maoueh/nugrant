require 'nugrant'
require 'nugrant/mixin/parameters'
require 'nugrant/vagrant/errors'

module Nugrant
  module Vagrant
    module V2
      module Config
        class User < ::Vagrant.plugin("2", :config)
          attr_reader :__current, :__user, :__system, :__defaults, :__all

          def initialize()
            compute_bags!({:params_filename => ".vagrantuser"})
          end

          include Mixin::Parameters
        end
      end
    end
  end
end
