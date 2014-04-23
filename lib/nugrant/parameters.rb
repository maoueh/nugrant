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
    #    Passed to Mixin::Parameters setup! method. See method
    #    for further information.
    #
    def initialize(config)
      setup!({}, config)
    end

    include Mixin::Parameters
  end
end
