require 'nugrant/mixin/parameters'

module Nugrant
  class Parameters

    include Mixin::Parameters

    ##
    # Create a new parameters object which holds completed
    # merged values. The following precedence is used to decide
    # which location has precedence over which location:
    #
    #    (Highest)  ------------------ (Lowest)
    #      project < user < system < defaults
    #
    # =| Arguments
    #  * `defaults`
    #    Passed to Mixin::Parameters setup! method. See mixin
    #    module for further information.
    #
    #  * `config`
    #    Passed to Mixin::Parameters setup! method. See mixin
    #    module for further information.
    #
    def initialize(defaults = {}, config = {}, options = {})
      setup!(defaults, config, options)
    end
  end
end
