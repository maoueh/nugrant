require 'nugrant/bag'
require 'nugrant/config'
require 'nugrant/helper/bag'
require 'nugrant/mixin/parameters'

module Nugrant
  class Parameters
    ##
    # Create a new parameters object which holds completed
    # merged values. The following precedence is used to decide
    # which location has precedence over which location:
    #
    #    (Highest)  ------------------ (Lowest)
    #      current < user < system < defaults
    #
    # =| Arguments
    #  * +:config+   - A hash that will be passed to Nugrant::Config.new() or
    #                  a Nugrant::Config instance directly.
    #                  See Nugrant::Config constructor for options that you can use.
    #  * +:defaults+ - The default values for the various parameters that will be read. This
    #                  must be a Hash object.
    #
    def initialize(config, defaults = {})
      compute_bags!(config, defaults)
    end

    include Mixin::Parameters
  end
end
