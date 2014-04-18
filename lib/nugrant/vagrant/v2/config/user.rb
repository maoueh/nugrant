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

          def method_missing(method, *args, &block)
            module_method = Mixin::Parameters.instance_method(:method_missing)

            # This calls method `method_missing` defined in Mixin::Parameters with self as the "called" instance
            module_method.bind(self).call(method, *args, &block)
          rescue KeyError
            raise Errors::ParameterNotFoundError, :key => method.to_s
          end
        end
      end
    end
  end
end
