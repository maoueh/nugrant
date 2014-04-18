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
    #      project < user < system < defaults
    #
    # =| Arguments
    #  * `config`
    #    A hash that will be passed to Nugrant::Config.new() or
    #    a Nugrant::Config instance directly.
    #    See Nugrant::Config constructor for options that you can use.
    #
    #  * `options`
    #    An options hash that is passed to Mixin::Parameters.compute_bags! method.
    #    See Mixin::Parameters.compute_bags! for details on the various options
    #    available.
    #
    def initialize(config, options = {})
      compute_bags!(config, options)
    end

    include Mixin::Parameters
  end
end
