require 'nugrant'

module Nugrant
  module Vagrant
    module V1
      module Config
        class User < ::Vagrant::Config::Base
          attr_reader :parameters

          def initialize()
            @parameters = Nugrant::Parameters.new()
          end

          def [](param_name)
            return @parameters[param_name]
          end

          def method_missing(method, *args, &block)
            return @parameters.method_missing(method, *args, &block)
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
