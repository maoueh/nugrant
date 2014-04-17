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
        @__defaults = Bag.new(elements)

        # When defaults change, we need to recompute parameters hierarchy
        compute_all!()
      end

      def compute_bags!(config, defaults = {})
        config = config.kind_of?(Nugrant::Config) ? config : Nugrant::Config.new(config)

        @__current = Helper::Bag.read(config.current_path, config.params_format)
        @__user = Helper::Bag.read(config.user_path, config.params_format)
        @__system = Helper::Bag.read(config.system_path, config.params_format)
        @__defaults = Bag.new(defaults)

        compute_all!()
      end

      ##
      # Recompute the correct precedences by merging the various
      # bag in the right order and return the result as a Nugrant::Bag
      # object.
      #
      def compute_all!()
        @__all = Bag.new()
        @__all.merge!(@__defaults)
        @__all.merge!(@__system)
        @__all.merge!(@__user)
        @__all.merge!(@__current)
      end
    end
  end
end
