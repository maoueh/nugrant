module Nugrant
  module Mixin
    ##
    # Mixin module so it's possible to share parameters
    # logic between default Parameters class and Vagrant
    # implementation.
    #
    # This method delegates method missing to the overall
    # bag instance. This means that even if the class
    # including this module doesn't inherit Bag directly,
    # it act exactly like one.
    #
    # To initialize the mixin module correctly, you must call
    # the compute_bags! method at least once to initialize
    # all variables. You should make this call in including
    # class' constructor directly.
    #
    module Parameters
      def method_missing(method, *args, &block)
        case
        when @__all.class.method_defined?(method)
          @__all.send(method, *args, &block)
        else
          @__all[method]
        end
      end

      def defaults()
        @__defaults
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
        @__defaults = Bag.new(elements, @__options)

        # When defaults change, we need to recompute parameters hierarchy
        compute_all!(@__options)
      end

      ##
      # Compute all parameters bags (current, user, system, default and all).
      #
      # =| Arguments
      #  * `config`
      #    The configuration object used to determine where to find the various
      #    bag source data. This can be either directly a `Nugrant::Config`
      #    object or a hash that will be pass to `Nugrant::Config` constructor.
      #
      #  * `options`
      #    An options hash where some customization option can be passed.
      #    Defaults to an empty hash, see options for specific option default
      #    values.
      #
      # =| Options
      #  * `:defaults`
      #    A hash that is used as the initial data for the defaults bag. Defaults
      #    to an empty hash.
      #
      #  * `:key_error`
      #    This option is passed to Bag.new constructor in it's options hash. See
      #    Bag.new for details on this options.
      #
      def compute_bags!(config, options = {})
        config = config.kind_of?(Nugrant::Config) ? config : Nugrant::Config.new(config)

        @__options = options

        @__current = Helper::Bag.read(config.current_path, config.params_format, options)
        @__user = Helper::Bag.read(config.user_path, config.params_format, options)
        @__system = Helper::Bag.read(config.system_path, config.params_format, options)
        @__defaults = Bag.new(options[:defaults] || {}, options)

        compute_all!(options)
      end

      ##
      # Recompute the correct precedences by merging the various
      # bag in the right order and return the result as a Nugrant::Bag
      # object.
      #
      def compute_all!(options = {})
        @__all = Bag.new({}, options)
        @__all.merge!(@__defaults)
        @__all.merge!(@__system)
        @__all.merge!(@__user)
        @__all.merge!(@__current)
      end
    end
  end
end
