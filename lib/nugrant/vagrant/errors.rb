require 'vagrant/errors'

module Nugrant
  module Vagrant
    module Errors
      class NugrantVagrantError < ::Vagrant::Errors::VagrantError
        error_namespace("nugrant.vagrant.errors")
      end

      class ParameterNotFoundError < NugrantVagrantError
        error_key(:parameter_not_found)
      end
    end
  end
end
