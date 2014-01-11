module Nugrant
  class Bag
    ##
    # The bag is Enumerable. For method using a key argument
    # the bag will accept symbol or string keys. For method
    # return keys, the bag will emit symbol keys.
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
    # This method always perform a deep merge and will deep merge
    # array scalar values only. This means that we do not merge
    # within array themselves.
    #
    def merge!(hash)
      bag = hash.kind_of?(Bag) ? hash : Bag.new(hash)

      bag.each do |key, value|
        if (current = @__elements[key]) == nil
          @__elements[key] = value
          next
        end

        case
          when current.kind_of?(Bag) && value.kind_of?(Bag)
            current.merge!(value)

          when current.kind_of?(Array) && value.kind_of?(Array)
            @__elements[key] = current | value

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
  end
end
