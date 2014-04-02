module Nugrant
  class Bag
    ##
    # The bag is Enumerable. For method using a key argument
    # the bag will accept symbol or string keys. For method
    # returning keys, the bag will emit symbol keys.
    include Enumerable

    attr_reader :__elements

    def initialize(elements = nil)
      clear!()
      update!(elements)
    end

    def [](key)
      key = __convert_key(key)
      raise KeyError, "Undefined parameter '#{key}'" if @__elements[key] == nil

      return @__elements[key]
    end

    def method_missing(method, *args, &block)
      return self[method]
    end

    def clear!()
      @__elements = {}
    end

    def each()
      @__elements.each do |key, value|
        yield key, value
      end
    end

    def empty?()
      @__elements.size() <= 0
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
      bag = hash.kind_of?(Bag) ? input : Bag.new(input)

      array_strategy = options[:array_strategy]
      bag.each do |key, value|
        current = @__elements[key]
        case
          when current == nil
            @__elements[key] = value

          when current.kind_of?(Bag) && value.kind_of?(Bag)
            current.merge!(value, :array_strategy => array_strategy)

          when current.kind_of?(Array) && value.kind_of?(Array)
            @__elements[key] = send("__#{array_strategy}_array_merge", current, value)

          when value != nil
            @__elements[key] = value
        end
      end
    end

    def update!(hash = nil)
      return if not (hash.kind_of?(Bag) or hash.kind_of?(Hash))

      hash.each do |key, value|
        case
          when value.kind_of?(Bag) || value.kind_of?(Hash)
            @__elements[__convert_key(key)] = Bag.new(value)

          else
            @__elements[__convert_key(key)] = value
        end
      end
    end

    def to_hash(options = {})
      return {} if empty?()

      use_string_key = options[:use_string_key]

      Hash[map do |key, value|
        key = key.to_s() if use_string_key

        [key, value.kind_of?(Bag) ? value.to_hash(options) : value]
      end]
    end

    ##
    ### Private Methods
    ##

    private

    def __convert_key(key)
      key.to_sym()
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
