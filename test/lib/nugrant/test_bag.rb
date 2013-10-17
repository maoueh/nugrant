require 'test/unit'

require 'nugrant/bag'

module Nugrant
  class TestBag < Test::Unit::TestCase
    def create_bag(parameters)
      return Bag.new(parameters)
    end

    def assert_all_access_equal(value, bag, key)
      assert_equal(value, bag.method_missing(key.to_sym), "bag.#{key.to_sym.inspect}")
      assert_equal(value, bag[key.to_s], "bag[#{key.to_s.inspect}]")
      assert_equal(value, bag[key.to_sym], "bag[#{key.to_sym.inspect}]")
    end

    def assert_all_access_bag(value, bag, key)
      assert_bag(value, bag.method_missing(key.to_sym))
      assert_bag(value, bag[key.to_s])
      assert_bag(value, bag[key.to_sym])
    end

    def assert_bag(parameters, bag)
      assert_kind_of(Bag, bag)

      parameters.each do |key, value|
        if not value.kind_of?(Hash)
          assert_all_access_equal(value, bag, key)
          next
        end

        assert_all_access_bag(value, bag, key)
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

      assert_raise(KeyError) do
        bag.invalid_value
      end

      assert_raise(KeyError) do
        bag["invalid_value"]
      end

      assert_raise(KeyError) do
        bag[:invalid_value]
      end
    end

    def test_to_hash()
      hash = create_bag({}).__to_hash()

      assert_kind_of(Hash, hash)
      assert_equal({}, hash)

      hash = create_bag({"value" => {:one => "value", "two" => "value"}}).__to_hash()

      assert_kind_of(Hash, hash)
      assert_kind_of(Hash, hash[:value])
      assert_kind_of(String, hash[:value][:one])
      assert_kind_of(String, hash[:value][:two])
      assert_equal({:value => {:one => "value", :two => "value"}}, hash)
    end

    def test_merge_array()
      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => [2, 3]})

      bag1.__merge!(bag2);

      assert_equal({:first => [1, 2, 3]}, bag1.__to_hash())

      bag1 = create_bag({"first" => [1, 2]})
      bag2 = create_bag({:first => "string"})

      bag1.__merge!(bag2);

      assert_equal({:first => "string"}, bag1.__to_hash())
    end
  end
end
