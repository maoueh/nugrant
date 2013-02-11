require 'nugrant'
require 'nugrant/parameters'
require 'test/unit'

class Nugrant::TestParameterBag < Test::Unit::TestCase
  def create_bag(parameters)
    return Nugrant::ParameterBag.new(parameters)
  end

  def assert_bag(parameters, bag)
    assert_kind_of(Nugrant::ParameterBag, bag)

    parameters.each do |key, value|
      if not value.is_a?(Hash)
        assert_equal(value, bag.send(key))
        assert_equal(value, bag[key])
        next
      end

      assert_bag(value, bag.send(key))
      assert_bag(value, bag[key])
    end
  end

  def run_test_bag(parameters)
    bag = create_bag(parameters)

    assert_bag(parameters, bag)
  end

  def test_bag()
    run_test_bag({"first" => "value1", "second" => "value2"})

    run_test_bag({
      "first" => {
        "level1" => "value1",
        "level2" => "value2",
      },
      "second" => {
        "level1" => "value3",
        "level2" => "value4",
      },
      "third" => "value5"
    })

    run_test_bag({
      "first" => {
        "level1" => {
          "level11" => "value1",
          "level12" => "value2",
        },
        "level2" => {
          "level21" => "value3",
          "level22" => "value4",
        },
        "level3" => "value5",
      },
      "second" => {
        "level1" => {
          "level11" => "value6",
          "level12" => "value7",
        },
        "level2" => {
          "level21" => "value8",
          "level22" => "value9",
        },
        "level3" => "value10",
      },
      "third" => "value11"
    })
  end

  def test_undefined_value()
    bag = create_bag({"value" => "one"})

    assert_raise(KeyError) do
      bag.invalid_value
    end

    assert_raise(KeyError) do
      bag["invalid_value"]
    end
  end
end
