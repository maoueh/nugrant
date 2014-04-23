require 'vagrant/errors'

require 'nugrant/helper/stack'

module Nugrant
  module Vagrant
    module Errors
      class NugrantVagrantError < ::Vagrant::Errors::VagrantError
        error_namespace("nugrant.vagrant.errors")

        def compute_context()
          Helper::Stack.fetch_error_region(caller(), {
            :matcher => /(.+Vagrantfile):([0-9]+)/
          })
        end
      end

      class ParameterNotFoundError < NugrantVagrantError
        error_key(:parameter_not_found)

        def initialize(options = nil, *args)
          super({:context => compute_context()}.merge(options || {}), *args)
        end
      end

      class VagrantUserParseError < NugrantVagrantError
        error_key(:parse_error)

        def initialize(options = nil, *args)
          super(options, *args)
        end
      end
    end
  end
end
