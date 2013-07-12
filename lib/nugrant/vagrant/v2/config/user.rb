require 'nugrant'

module Nugrant
  module Vagrant
    module V2
      module Config
        class User < ::Vagrant.plugin("2", :config)
          attr_reader :parameters

          def initialize()
            @parameters = Nugrant::Parameters.new({:config => {:params_filename => ".vagrantuser"}})
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
