require 'nugrant'
require 'nugrant/vagrant/errors'

module Nugrant
  module Vagrant
    module V2
      module Config
        class User < ::Vagrant.plugin("2", :config)
          attr_reader :__parameters



          def initialize()
            @__parameters = Nugrant::Parameters.new({:config => {:params_filename => ".vagrantuser"}})
          end

          def [](param_name)
            return @__parameters[param_name]
          rescue KeyError
            raise Errors::ParameterNotFoundError, :key => param_name
          end

          def method_missing(method, *args, &block)
            [method]
          end

          def each(&block)
            @__parameters.each(&block)
          end

          def has?(key)
            @__parameters.has?(key)
          end

          def defaults(parameters)
            @__parameters.defaults(parameters)
          end

          def defaults=(parameters)
            @__parameters.defaults=(parameters)
          end
        end
      end
    end
  end
end
