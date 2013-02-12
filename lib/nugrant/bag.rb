module Nugrant
  class Bag
    def initialize(hash)
      @bag = recompute(hash)
    end

    def recompute(hash)
      @bag = {}
      return @bag if hash == nil

      hash.each do |key, value|
        if not value.is_a?(Hash)
          @bag[key] = value
          next
        end

        # It is a hash, transform it into a bag
        @bag[key] = Nugrant::Bag.new(value)
      end

      return @bag
    end

    def [](key)
      return fetch(key)
    end

    def method_missing(method, *args, &block)
      return fetch(method.to_s)
    end

    def has_key?(key)
      return @bag.has_key?(key)
    end

    def fetch(key)
      if not has_key?(key)
        raise KeyError, "Undefined parameter '#{key}'"
      end

      return @bag[key]
    end
  end
end
