require 'nugrant/mixin/parameters'
require 'nugrant/vagrant/errors'

module Nugrant
  module Vagrant
    module V2
      module Config
        class User < ::Vagrant.plugin("2", :config)

          include Mixin::Parameters

          def initialize(defaults = {}, config = {})
            setup!(defaults,
              :params_filename => ".vagrantuser",
              :key_error => Proc.new do |key|
                raise Errors::ParameterNotFoundError, :key => key.to_s
              end,
              :parse_error => Proc.new do |filename, error|
                raise Errors::VagrantUserParseError, :filename => filename.to_s, :error => error
              end
            )
          end


        end
      end
    end
  end
end
