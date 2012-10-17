require 'nugrant'
require 'nugrant/parameters'
require 'test/unit'

class Nugrant::TestParameters < Test::Unit::TestCase
  def create_parameters(local_params_filename, global_params_filename)
    resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../resources")

    return Nugrant::create_parameters(resource_path, local_params_filename, global_params_filename)
  end

  def assert_level(parameters, level_name)
    level = parameters.send(level_name)
    assert_equal("#{level_name}_overriden1", level.first)
    assert_equal("#{level_name}_value2", level.second)
    assert_equal("#{level_name}_added3", level.third)

    level = parameters[level_name]
    assert_equal("#{level_name}_overriden1", level["first"])
    assert_equal("#{level_name}_value2", level["second"])
    assert_equal("#{level_name}_added3", level["third"])
  end

  def test_params_level_1()
    parameters = create_parameters("params_local_1.yml", "params_global_1.yml")

    assert_equal("overriden1", parameters.first)
    assert_equal("value2", parameters.second)
    assert_equal("added3", parameters.third)

    assert_equal("overriden1", parameters["first"])
    assert_equal("value2", parameters["second"])
    assert_equal("added3", parameters["third"])
  end

  def test_params_level_2()
    parameters = create_parameters("params_local_2.yml", "params_global_2.yml")

    assert_level(parameters, "level1")
    assert_level(parameters, "level2")
    assert_level(parameters, "level3")
  end
end
