module Nugrant
  module Mixin
    ##
    # Mixin module so it's possible to share parameters
    # logic between default Parameters class and Vagrant
    # implementation.
    #
    module Parameters
      include Enumerable

      def [](key)
        return @__all[key]
      end

      def method_missing(method, *args, &block)
        return @__all[method]
      end

      def empty?()
        @__all.empty?()
      end

      def has?(key)
        return @__all.include?(key)
      end

      def each(&block)
        @__all.each(&block)
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

      def to_hash()
        @__all.to_hash()
      end
    end
  end
end
