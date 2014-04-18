require 'minitest/autorun'

require 'nugrant/bag'
require 'nugrant/helper/bag'

module Nugrant
  class TestBag < ::Minitest::Test
    def create_bag(elements, options = {})
      return Bag.new(elements, options)
    end

    def assert_all_access_equal(expected, bag, key)
      assert_equal(expected, bag.method_missing(key.to_sym), "bag.#{key.to_sym}")
      assert_equal(expected, bag[key.to_s], "bag[#{key.to_s}]")
      assert_equal(expected, bag[key.to_sym], "bag[#{key.to_sym}]")
    end

    def assert_all_access_bag(expected, bag, key)
      assert_bag(expected, bag.method_missing(key.to_sym))
      assert_bag(expected, bag[key.to_s])
      assert_bag(expected, bag[key.to_sym])
    end

    def assert_bag(expected, bag)
      assert_kind_of(Bag, bag)

      expected.each do |key, expected_value|
        if not expected_value.kind_of?(Hash)
          assert_all_access_equal(expected_value, bag, key)
          next
        end

        assert_all_access_bag(expected_value, bag, key)
      end
    end

    def run_test_bag(parameters)
      bag = create_bag(parameters)

      assert_bag(parameters, bag)
    end

    def test_bag()
      run_test_bag({:first => "value1", :second => "value2"})

      run_test_bag({
        :first => {
          :level1 => "value1",
          :level2 => "value2",
        },
        :second => {
          :level1 => "value3",
          :level2 => "value4",
        },
        :third => "value5"
      })

      run_test_bag({
        :first => {
          :level1 => {
            :level11 => "value1",
            :level12 => "value2",
          },
          :level2 => {
            :level21 => "value3",
            :level22 => "value4",
          },
          :level3 => "value5",
        },
        :second => {
          :level1 => {
            :level11 => "value6",
            :level12 => "value7",
          },
          :level2 => {
            :level21 => "value8",
            :level22 => "value9",
          },
          :level3 => "value10",
        },
        :third => "value11"
      })
    end

    def test_undefined_value()
      bag = create_bag({:value => "one"})

      assert_raises(KeyError) do
        bag.invalid_value
      end

      assert_raises(KeyError) do
        bag["invalid_value"]
      end

      assert_raises(KeyError) do
        bag[:invalid_value]
      end
    end

    def test_to_hash()
      hash = create_bag({}).to_hash()

      assert_kind_of(Hash, hash)
      assert_equal({}, hash)

      hash = create_bag({"value" => {:one => "value", "two" => "value"}}).to_hash()

      assert_kind_of(Hash, hash)
      assert_kind_of(Hash, hash[:value])
      assert_kind_of(String, hash[:value][:one])
      assert_kind_of(String, hash[:value][:two])
      assert_equal({:value => {:one => "value", :two => "value"}}, hash)
    end

    def test_merge_array_replace()
      # Replace should be the default case
      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => [2, 3]})

      bag1.merge!(bag2);

      assert_equal({:first => [2, 3]}, bag1.to_hash())

      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => "string"})

      bag1.merge!(bag2);

      assert_equal({:first => "string"}, bag1.to_hash())
    end

    def test_merge_array_extend()
      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => [2, 3]})

      bag1.merge!(bag2, :array_strategy => :extend);

      assert_equal({:first => [1, 2, 3]}, bag1.to_hash())

      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => "string"})

      bag1.merge!(bag2, :array_strategy => :extend);

      assert_equal({:first => "string"}, bag1.to_hash())
    end

    def test_merge_array_concat()
      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => [2, 3]})

      bag1.merge!(bag2, :array_strategy => :concat);

      assert_equal({:first => [1, 2, 2, 3]}, bag1.to_hash())

      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => "string"})

      bag1.merge!(bag2, :array_strategy => :concat);

      assert_equal({:first => "string"}, bag1.to_hash())
    end

    def test_nil_key()
      assert_raises(ArgumentError) do
        create_bag({nil => "value"})
      end

      parameters = create_bag({})

      assert_raises(ArgumentError) do
        parameters[nil] = 1
      end

      assert_raises(ArgumentError) do
        parameters[nil]
      end

      assert_raises(ArgumentError) do
        parameters.method_missing(nil)
      end
    end

    def test_restricted_keys_are_still_accessible
      keys = Helper::Bag.restricted_keys()
      bag = create_bag(Hash[
        keys.map do |key|
          [key, "#{key.to_s} - value"]
        end
      ])

      keys.each do |key|
        assert_equal("#{key.to_s} - value", bag[key.to_s], "bag[#{key.to_s}]")
        assert_equal("#{key.to_s} - value", bag[key.to_sym], "bag[#{key.to_sym}]")
      end
    end

    def test_custom_key_error_handler
      bag = create_bag({:value => "one"}, :key_error => Proc.new do |key|
        raise IndexError
      end)

      assert_raises(IndexError) do
        bag.invalid_value
      end

      assert_raises(IndexError) do
        bag["invalid_value"]
      end

      assert_raises(IndexError) do
        bag[:invalid_value]
      end
    end

    def test_custom_key_error_handler_returns_value
      bag = create_bag({:value => "one"}, :key_error => Proc.new do |key|
        "Some value"
      end)

      assert_equal("Some value", bag.invalid_value)
      assert_equal("Some value", bag["invalid_value"])
      assert_equal("Some value", bag[:invalid_value])
    end
  end
end
