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
    # This module delegates method missing to the final
    # bag hierarchy (@__all). This means that even if the class
    # including this module doesn't inherit Bag directly,
    # it act exactly like one.
    #
    # When including this module, you must respect an important
    # constraint.
    #
    # The including class must call `setup!` before starting using
    # parameters retrieval. This is usually performed in
    # the `initialize` method directly but could be in a different place
    # depending on the including class lifecycle. The call to `setup!` is
    # important to initialize all required instance variables.
    #
    # Here an example where `setup!` is called in constructor. Your constructor
    # does not need to have these arguments, they are there as an example.
    #
    # ```
    #     def initialize(defaults = {}, config = {}, options = {})
    #       setup!(defaults, config, options)
    #     end
    # ```
    #
    module Parameters
      attr_reader :__config, :__current, :__user, :__system, :__defaults, :__all

      def method_missing(method, *args, &block)
        case
        when @__all.class.method_defined?(method)
          @__all.send(method, *args, &block)
        else
          @__all[method]
        end
      end

      def array_merge_strategy
        @__config.array_merge_strategy
      end

      def auto_export
        @__config.auto_export
      end

      def auto_export_script_path
        @__config.auto_export_script_path
      end

      ##
      # Change the current array merge strategy for this parameters.
      #
      # @param strategy The new strategy to use.
      def array_merge_strategy=(strategy)
        return if not Nugrant::Config.supported_array_merge_strategy(strategy)

        @__config.array_merge_strategy = strategy

        # When array_merge_strategy change, we need to recompute parameters hierarchy
        compute_all!()
      end

      def auto_export=(auto_export)
        @__config.auto_export = auto_export
      end

      def auto_export_script_path=(path)
        @__config.auto_export_script_path = path
      end

      def defaults()
        @__defaults
      end

      ##
      # Set the new default values for the
      # various parameters contain by this instance.
      # This will call `compute_all!` to recompute
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

      def merge(other)
        result = dup()
        result.merge!(other)
      end

      def merge!(other)
        @__config.merge!(other.__config)

        # Updated Bags' config
        @__current.config = @__config
        @__user.config = @__config
        @__system.config = @__config
        @__defaults.config = @__config

        # Merge other into Bags
        @__current.merge!(other.__current, :array_merge_strategy => :replace)
        @__user.merge!(other.__user, :array_merge_strategy => :replace)
        @__system.merge!(other.__system, :array_merge_strategy => :replace)
        @__defaults.merge!(other.__defaults, :array_merge_strategy => :replace)

        # Recompute all from merged Bags
        compute_all!()

        self
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
      #    convert method. Used to determine where to find the various
      #    bag data sources and other configuration options.
      #
      #    Passed to nested structures that requires a Nugrant::Config object
      #    like the Bag object and Helper::Bag module.
      #
      #  * `options`
      #    Options hash used by this method exclusively. No options yet, added
      #    for future improvements.
      #
      def setup!(defaults = {}, config = {}, options = {})
        @__config = Nugrant::Config::convert(config);

        @__defaults = Bag.new(defaults, @__config)
        @__current = Helper::Bag.read(@__config.current_path, @__config.params_format, @__config)
        @__user = Helper::Bag.read(@__config.user_path, @__config.params_format, @__config)
        @__system = Helper::Bag.read(@__config.system_path, @__config.params_format, @__config)

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
