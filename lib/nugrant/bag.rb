module Nugrant
  class Bag < Hash

    def initialize(elements = {})
      super()

      (elements || {}).each do |key, value|
        self[key] = value.kind_of?(Hash) ? Bag.new(value) : value
      end
    end

    def method_missing(method, *args, &block)
      return self[method]
    end

    ##
    ### Hash Overriden Methods (for string & symbol indifferent access)
    ##

    def [](input)
      key = __convert_key(input)
      raise KeyError, "Undefined parameter '#{key}'" if not key?(key)

      super(key)
    end

    def []=(input, value)
      super(__convert_key(input), value)
    end

    def key?(key)
      super(__convert_key(key))
    end

    ##
    # This method first start by converting the `input` parameter
    # into a bag. It will then *deep* merge current values with
    # the new ones coming from the `input`.
    #
    # The array merge strategy is by default to replace current
    # values with new ones. You can use option `:array_strategy`
    # to change this default behavior.
    #
    # +Options+
    #  * :array_strategy
    #     * :replace (Default) => Replace current values by new ones
    #     * :extend => Merge current values with new ones
    #     * :concat => Append new values to current ones
    #
    def merge!(input, options = {})
      options = {:array_strategy => :replace}.merge(options)

      array_strategy = options[:array_strategy]
      input.each do |key, value|
        current = __get(key)
        case
          when current == nil
            self[key] = value

          when current.kind_of?(Hash) && value.kind_of?(Hash)
            current.merge!(value, options)

          when current.kind_of?(Array) && value.kind_of?(Array)
            self[key] = send("__#{array_strategy}_array_merge", current, value)

          when value != nil
            self[key] = value
        end
      end
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

    ##
    ### Aliases
    ##

    alias_method :to_ary, :to_a

    ##
    ### Private Methods
    ##

    private

    def __convert_key(key)
      return key.to_sym() if key.respond_to?(:to_sym)

      raise ArgumentError, "Key cannot be converted to symbol, current value [#{key}] (#{key.class.name})"
    end

    def __get(key)
      # Calls Hash method [__convert_key(key)], used internally to retrieve value without raising Undefined parameter
      self.class.superclass.instance_method(:[]).bind(self).call(__convert_key(key))
    end

    def __concat_array_merge(current_array, new_array)
      current_array + new_array
    end

    def __extend_array_merge(current_array, new_array)
      current_array | new_array
    end

    def __replace_array_merge(current_array, new_array)
      new_array
    end
  end
end
