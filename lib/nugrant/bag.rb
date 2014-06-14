require 'nugrant/config'

module Nugrant
  class Bag < Hash

    ##
    # Create a new Bag object which holds key/value pairs.
    # The Bag object inherits from the Hash object, the main
    # differences with a normal Hash are indifferent access
    # (symbol or string) and method access (via method call).
    #
    # Hash objects in the map are converted to Bag. This ensure
    # proper nesting of functionality.
    #
    # =| Arguments
    #  * `elements`
    #    The initial elements the bag should be built with it.'
    #    Must be an object responding to `each` and accepting
    #    a block with two arguments: `key, value`. Defaults to
    #    the empty hash.
    #
    #  * `config`
    #    A Nugrant::Config object or hash passed to Nugrant::Config
    #    constructor. Used for `key_error` handler.
    #
    def initialize(elements = {}, config = {})
      super()

      @__config = Config::convert(config)

      (elements || {}).each do |key, value|
        self[key] = value
      end
    end

    def method_missing(method, *args, &block)
      self[method]
    end

    ##
    ### Enumerable Overridden Methods (for string & symbol indifferent access)
    ##

    def count(item)
      super(__try_convert_item(item))
    end

    def find_index(item = nil, &block)
      block_given? ? super(&block) : super(__try_convert_item(item))
    end

    ##
    ### Hash Overridden Methods (for string & symbol indifferent access)
    ##

    def [](input)
      key = __convert_key(input)
      return @__config.key_error.call(key) if not key?(key)

      super(key)
    end

    def []=(input, value)
      super(__convert_key(input), __convert_value(value))
    end

    def assoc(key)
      super(__convert_key(key))
    end

    def delete(key)
      super(__convert_key(key))
    end

    def fetch(key, default = nil)
      super(__convert_key(key), default)
    end

    def has_key?(key)
      super(__convert_key(key))
    end

    def include?(item)
      super(__try_convert_item(item))
    end

    def key?(key)
      super(__convert_key(key))
    end

    def member?(item)
      super(__try_convert_item(item))
    end

    def merge!(input)
      input.each do |key, value|
        current = __get(key)
        case
          when current == nil
            self[key] = value

          when current.kind_of?(Hash) && value.kind_of?(Hash)
            current.merge!(value)

          when current.kind_of?(Array) && value.kind_of?(Array)
            self[key] = send("__#{@__config.array_merge_strategy}_array_merge", current, value)

          when value != nil
            self[key] = value
        end
      end
    end

    def store(key, value)
      self[key] = value
    end

    def to_hash(options = {})
      return {} if empty?()

      use_string_key = options[:use_string_key]

      Hash[map do |key, value|
        key = use_string_key ? key.to_s() : key
        value = value.kind_of?(Bag) ? value.to_hash(options) : value

        [key, value]
      end]
    end

    def walk(path = [], &block)
      each do |key, value|
        nested_bag = value.kind_of?(Nugrant::Bag)

        value.walk(path + [key], &block) if nested_bag
        yield path + [key], key, value if not nested_bag
      end
    end

    alias_method :to_ary, :to_a

    ##
    ### Private Methods
    ##

    private

    def __convert_key(key)
      return key.to_sym() if key.respond_to?(:to_sym)

      raise ArgumentError, "Key cannot be converted to symbol, current value [#{key}] (#{key.class.name})"
    end

    ##
    # This function change value convertible to Bag into actual Bag.
    # This trick enable deeply using all Bag functionalities and also
    # ensures at the same time a deeply preventive copy since a new
    # instance is created for this nested structure.
    #
    # @param value The value to convert to bag if necessary
    # @return The converted value
    #
    def __convert_value(value)
      value.kind_of?(Hash) ? Bag.new(value, @__config) : value
    end

    def __get(key)
      # Calls Hash method [__convert_key(key)], used internally to retrieve value without raising Undefined parameter
      self.class.superclass.instance_method(:[]).bind(self).call(__convert_key(key))
    end

    ##
    # The concat order is the reversed compared to others
    # because we assume that new values have precedence
    # over current ones. Hence, the are prepended to
    # current values. This is also logical for parameters
    # because of the order in which bags are merged.
    #
    def __concat_array_merge(current_array, new_array)
      new_array + current_array
    end

    def __extend_array_merge(current_array, new_array)
      current_array | new_array
    end

    def __replace_array_merge(current_array, new_array)
      new_array
    end

    def __try_convert_item(args)
      return [__convert_key(args[0]), args[1]] if args.kind_of?(Array)

      __convert_key(args)
    rescue
      args
    end
  end
end
