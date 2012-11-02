module Nugrant
  class ParameterBag
    def initialize(parameters)
      if parameters == nil
        return
      end

      @bag = {}
      @defaults = {}

      parameters.each do |key, value|
        if key == "defaults"
          throw ArgumentError, "The key 'defaults' has restricted usage and cannot be defined"
        end

        if not value.is_a?(Hash)
          @bag[key] = value
          next
        end

        # It is a hash, transform it into a bag
        @bag[key] = Nugrant::ParameterBag.new(value)
      end
    end

    def [](param_name)
      return get_param(param_name)
    end

    def method_missing(method, *args, &block)
      return get_param(method.to_s)
    end

    def has_param?(param_name)
      return @bag != nil && @bag.has_key?(param_name)
    end

    def get_param(param_name)
      if not has_param?(param_name)
        if @defaults[param_name]
          return @defaults[param_name]
        end

        throw KeyError, "Undefined parameter: '#{param_name}'"
      end

      return @bag[param_name]
    end

    def get_params()
      return @bag
    end

    def defaults(parameters)
      parameters.each do |key, value|
        if value.is_a?(Hash) and has_param?(key)
          @bag[key].defaults(value)
        end
      end

      @defaults = self.class.new(parameters)
    end

    def defaults=(parameters)
      defaults(parameters)
    end
  end
end
