require 'nugrant/bag'
require 'nugrant/config'
require 'nugrant/helper/bag'

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

      def array_merge_strategy
        @__config.array_merge_strategy
      end

      def array_merge_strategy=(strategy)
        return if not Nugrant::Config.supported_array_merge_strategy(strategy)

        @__config.array_merge_strategy = strategy

        # When array_merge_strategy change, we need to recompute parameters hierarchy
        compute_all!()
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
        @__defaults = Bag.new(elements, @__config)

        # When defaults change, we need to recompute parameters hierarchy
        compute_all!()
      end

      ##
      # Setup instance variables of the mixin. It will compute all parameters bags
      # (current, user, system, default and all) and stored them to these respective
      # instance variables:
      #
      #  * @__current
      #  * @__user
      #  * @__system
      #  * @__defaults
      #
      # =| Arguments
      #  * `defaults`
      #    A hash that is used as the initial data for the defaults bag. Defaults
      #    to an empty hash.
      #
      #  * `config`
      #    A Nugrant::Config object or hash passed to Nugrant::Config
      #    constructor. Used to determine where to find the various
      #    bag data sources.
      #
      #    Passed to nested structures that require nugrant configuration
      #    parameters like the Bag object and Helper::Bag module.
      #
      def setup!(defaults = {}, config = {})
        @__config = Nugrant::Config::convert(config);

        @__current = Helper::Bag.read(@__config.current_path, @__config.params_format, @__config)
        @__user = Helper::Bag.read(@__config.user_path, @__config.params_format, @__config)
        @__system = Helper::Bag.read(@__config.system_path, @__config.params_format, @__config)
        @__defaults = Bag.new(defaults, @__config)

        compute_all!()
      end

      ##
      # Recompute the correct precedences by merging the various
      # bag in the right order and return the result as a Nugrant::Bag
      # object.
      #
      def compute_all!()
        @__all = Bag.new({}, @__config)
        @__all.merge!(@__defaults)
        @__all.merge!(@__system)
        @__all.merge!(@__user)
        @__all.merge!(@__current)
      end
    end
  end
end
