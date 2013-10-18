require 'vagrant/errors'

require 'nugrant/helper/stack'

module Nugrant
  module Vagrant
    module Errors
      class NugrantVagrantError < ::Vagrant::Errors::VagrantError
        error_namespace("nugrant.vagrant.errors")
      end

      class ParameterNotFoundError < NugrantVagrantError
        error_key(:parameter_not_found)

        def initialize(options = nil, *args)
          super({:context => compute_context()}.merge(options || {}), *args)
        end

        def compute_context()
          Helper::Stack.find_error_location(caller(), {
            :matcher => /(.+Vagrantfile):([0-9]+)/
          })
        end
      end
    end
  end
end
