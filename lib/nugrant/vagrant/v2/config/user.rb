require 'nugrant'
require 'nugrant/vagrant/errors'

module Nugrant
  module Vagrant
    module V2
      module Config
        class User < ::Vagrant.plugin("2", :config)
          attr_reader :parameters

          def initialize()
            @parameters = Nugrant::Parameters.new()
          end

          def [](param_name)
            return @parameters[param_name]
          rescue KeyError
            raise Errors::ParameterNotFoundError, :key => param_name
          end

          def method_missing(method, *args, &block)
            return @parameters.method_missing(method, *args, &block)
          rescue KeyError
            raise Errors::ParameterNotFoundError, :key => method
          end

          def each(&block)
            @parameters.each(&block)
          end

          def defaults(parameters)
            @parameters.defaults(parameters)
          end

          def defaults=(parameters)
            @parameters.defaults=(parameters)
          end
        end
      end
    end
  end
end
