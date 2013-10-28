module Nugrant
  class Bag
    attr_reader :__elements

    def initialize(elements = nil)
      if elements.kind_of?(Bag)
        @__elements = elements
      end

      __recompute(elements)
    end

    def [](key)
      return __fetch(key)
    end

    def method_missing(method, *args, &block)
      return __fetch(method)
    end

    def has?(key)
      return @__elements.has_key?(key.to_sym)
    end

    def empty?()
      @__elements.size() <= 0
    end

    ##
    # This method always perform a deep merge and will deep merge
    # array scalar values only. This means that we do not merge
    # within array themselves.
    #
    def __merge!(elements)
      bag = elements.kind_of?(Bag) ? elements : Bag.new(elements)
      return if bag.empty?()

      bag.each do |key, value|
        if has?(key)
          current = @__elements[key]
          if current.kind_of?(Bag) and value.kind_of?(Bag)
            current.__merge!(value)
          elsif current.kind_of?(Array) and value.kind_of?(Array)
            @__elements[key] = current | value
          elsif value != nil
            @__elements[key] = value
          end

          next
        end

        @__elements[key] = value
      end
    end

    def each()
      @__elements.each do |key, value|
        yield key, value
      end
    end

    def __to_hash(options = {})
      return {} if empty?()

      string_key = options[:string_key]

      hash = {}
      each do |key, value|
        key = key.to_s() if string_key

        hash[key] = value.kind_of?(Bag) ? value.__to_hash(:string_key => string_key) : value
      end

      return hash
    end

    def __recompute(hash = nil)
      @__elements = {}
      return if hash == nil or not hash.kind_of?(Hash)

      hash.each do |key, value|
        if not value.kind_of?(Hash)
          @__elements[key.to_sym] = value
          next
        end

        # It is a hash, transform it into a bag
        @__elements[key.to_sym] = Bag.new(value)
      end
    end

    def __fetch(key)
      if not has?(key)
        raise KeyError, "Undefined parameter '#{key}'"
      end

      return @__elements[key.to_sym]
    end
  end
end
