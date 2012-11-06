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

  def test_restricted_key_defaults()
    assert_raise(ArgumentError) do
      results = create_bag({"defaults" => "one"})
      puts("Results: #{results.inspect} (Should have thrown!)")
    end

    assert_raise(ArgumentError) do
      results = create_bag({"level" => {"defaults" => "value"}})
      puts("Results: #{results.inspect} (Should have thrown!)")
    end
  end

  def test_defaults()
    run_test_defaults({
      "first" => {
        "level1" => "value1",
        "level2" => "value2",
        "deeper" => {
          "level3" => "value3"
        }
      },
    }, {
      "first" => {
        "level1" => "default1",
        "level3" => "default3",
        "deeper" => {
          "level3" => "default3",
          "level4" => "value4"
        }
      },
      "second" => {
        "level1" => "default1"
      },
      "third" => "default3"
    }, {
      "first" => {
        "level1" => "value1",
        "level2" => "value2",
        "level3" => "default3",
        "deeper" => {
          "level3" => "value3",
          "level4" => "value4"
        }
      },
      "second" => {
        "level1" => "default1"
      },
      "third" => "default3"
    })
  end

  def test_defaults_empty()
    defaults = {
      "first" => {
        "second" => {
          "third" => {
            "value1" => "one",
            "value2" => "two"
          },
          "fourth" => "third",
        },
        "fifth" => "four"
      }
    }

    run_test_defaults({}, defaults, defaults)
  end

  def run_test_defaults(parameters, parameters_defaults, expected)
    bag = create_bag(parameters)
    bag.defaults(parameters_defaults)

    assert_bag(expected, bag)

    bag = create_bag(parameters)
    bag.defaults = parameters_defaults

    assert_bag(expected, bag)
  end
end
