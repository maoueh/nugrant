require 'nugrant/bag'
require 'nugrant/helper/bag'

module Nugrant
  class Parameters
    attr_reader :__current, :__user, :__system, :__defaults, :__all

    ##
    # Create a new parameters object which holds completed
    # merged values. The following precedence is used to decide
    # which location has precedence over which location:
    #
    #    (Highest)  ------------------ (Lowest)
    #      current < user < system < defaults
    #
    # =| Options
    #  * +:config+   - A hash that will be passed to Nugrant::Config.new().
    #                  See Nugrant::Config constructor for options that you can use.
    #  * +:defaults+ - The default values for the various parameters that will be read. This
    #                  must be a Hash object.
    #
    def initialize(options = {})
      @__config = Config.new(options[:config])

      @__current = Helper::Bag.read(@__config.current_path, @__config.params_format)
      @__user = Helper::Bag.read(@__config.user_path, @__config.params_format)
      @__system = Helper::Bag.read(@__config.system_path, @__config.params_format)
      @__defaults = Bag.new(options[:defaults] || {})

      __compute_all()
    end

    def [](key)
      return @__all[key]
    end

    def method_missing(method, *args, &block)
      return  @__all[method]
    end

    def empty?()
      @__all.empty?()
    end

    def has?(key)
      return @__all.has?(key)
    end

    def each(&block)
      @__all.each(&block)
    end

    ##
    # Set the new default values for the
    # various parameters contain by this instance.
    # This will call __compute_all() to recompute
    # correct precedences.
    #
    # =| Attributes
    #  * +elements+ - The new default elements
    #
    def defaults=(elements)
      @__defaults = Bag.new(elements)

      # When defaults change, we need to recompute parameters hierarchy
      __compute_all()
    end

    ##
    # Recompute the correct precedences by merging the various
    # bag in the right order and return the result as a Nugrant::Bag
    # object.
    #
    def __compute_all()
      @__all = Bag.new()
      @__all.__merge!(@__defaults)
      @__all.__merge!(@__system)
      @__all.__merge!(@__user)
      @__all.__merge!(@__current)
    end

    def __to_hash()
      @__all.__to_hash()
    end
  end
end
