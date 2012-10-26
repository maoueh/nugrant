require 'nugrant'
require 'nugrant/parameters'
require 'test/unit'

class Nugrant::TestParameters < Test::Unit::TestCase

  @@PARAMS_FILETYPES = ["json", "yml"]

  def create_parameters(params_filetype, project_params_filename, user_params_filename)
    resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../resources/#{params_filetype}")

    project_params_path = "#{resource_path}/#{project_params_filename}.#{params_filetype}" if project_params_filename
    user_params_path = "#{resource_path}/#{user_params_filename}.#{params_filetype}" if project_params_filename and user_params_filename

    return Nugrant::create_parameters({
      :params_filetype => params_filetype,
      :project_params_path => project_params_path,
      :user_params_path => user_params_path,
    })
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
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_project_1", "params_user_1")

      assert_equal("overriden1", parameters.first)
      assert_equal("value2", parameters.second)
      assert_equal("added3", parameters.third)

      assert_equal("overriden1", parameters["first"])
      assert_equal("value2", parameters["second"])
      assert_equal("added3", parameters["third"])
    end
  end

  def test_params_level_2()
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_project_2", "params_user_2")

      assert_level(parameters, "level1")
      assert_level(parameters, "level2")
      assert_level(parameters, "level3")
    end
  end

  def test_file_nil()
    run_test_file_invalid("impossible_file_path.yml.impossible")
  end

  def test_file_does_not_exist()
    run_test_file_invalid("impossible_file_path.yml.impossible")
  end

  def run_test_file_invalid(invalid_value)
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, invalid_value, "params_simple")
      assert_equal("value", parameters.test)
      assert_equal("value", parameters["test"])

      parameters = create_parameters(params_filetype, "params_simple", invalid_value)
      assert_equal("value", parameters.test)
      assert_equal("value", parameters["test"])

      parameters = create_parameters(params_filetype, invalid_value, invalid_value)
      assert_not_nil(parameters)
    end
  end

  def test_params_windows_eol()
    run_test_params_eol("params_windows_eol")
  end

  def test_params_unix_eol()
    run_test_params_eol("params_unix_eol")
  end

  def run_test_params_eol(file_path)
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_unix_eol", "impossible_file_path.yml.impossible")

      assert_equal("value1", parameters.level1)
      assert_equal("value2", parameters.level2.first)
    end
  end

  def filetypes()
    @@PARAMS_FILETYPES
  end
end
