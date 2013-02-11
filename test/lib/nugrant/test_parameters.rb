require 'nugrant'
require 'nugrant/parameters'
require 'test/unit'

class Nugrant::TestParameters < Test::Unit::TestCase

  @@PARAMS_FILETYPES = ["json", "yml"]
  @@INVALID_PATH = "impossible_file_path.yml.impossible"

  def create_parameters(params_filetype, project_params_filename, user_params_filename, system_params_filename)
    resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../resources/#{params_filetype}")

    project_params_path = "#{resource_path}/#{project_params_filename}.#{params_filetype}" if project_params_filename
    user_params_path = "#{resource_path}/#{user_params_filename}.#{params_filetype}" if user_params_filename
    system_params_path = "#{resource_path}/#{system_params_filename}.#{params_filetype}" if system_params_filename

    return Nugrant::create_parameters({
      :params_filetype => params_filetype,
      :project_params_path => project_params_path,
      :user_params_path => user_params_path,
      :system_params_path => system_params_path
    })
  end

  def assert_level(parameters, results)
    results.each do |key, value|
      assert_equal(value, parameters.send(key), "method(#{key})")
      assert_equal(value, parameters[key], "array[#{key}]")
    end

    assert_equal(false, parameters.has_param?("0.0.0"))
  end

  def test_params_level_1()
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_project_1", "params_user_1", "params_system_1")

      assert_level(parameters, {
        "1.1.1" => "project",
        "1.1.0" => "project",
        "1.0.1" => "project",
        "0.1.1" => "user",
        "1.0.0" => "project",
        "0.1.0" => "user",
        "0.0.1" => "system",
      })
    end
  end

  def test_params_level_2()
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_project_2", "params_user_2", "params_system_2")

      run_second_level(parameters, "1.1.1", {
        "1.1.1" => "project",
        "1.1.0" => "project",
        "1.0.1" => "project",
        "0.1.1" => "user",
        "1.0.0" => "project",
        "0.1.0" => "user",
        "0.0.1" => "system",
      })

      run_second_level(parameters, "1.1.0", {
        "1.1.1" => "project",
        "1.1.0" => "project",
        "1.0.1" => "project",
        "0.1.1" => "user",
        "1.0.0" => "project",
        "0.1.0" => "user",
      })

      run_second_level(parameters, "1.0.1", {
        "1.1.1" => "project",
        "1.1.0" => "project",
        "1.0.1" => "project",
        "0.1.1" => "system",
        "1.0.0" => "project",
        "0.0.1" => "system",
      })

      run_second_level(parameters, "0.1.1", {
        "1.1.1" => "user",
        "1.1.0" => "user",
        "1.0.1" => "system",
        "0.1.1" => "user",
        "0.1.0" => "user",
        "0.0.1" => "system",
      })

      run_second_level(parameters, "1.0.0", {
        "1.1.1" => "project",
        "1.1.0" => "project",
        "1.0.1" => "project",
        "1.0.0" => "project",
      })

      run_second_level(parameters, "0.1.0", {
        "1.1.1" => "user",
        "1.1.0" => "user",
        "0.1.1" => "user",
        "0.1.0" => "user",
      })

      run_second_level(parameters, "0.0.1", {
        "1.1.1" => "system",
        "1.0.1" => "system",
        "0.1.1" => "system",
        "0.0.1" => "system",
      })

      assert_equal(false, parameters.has_param?("0.0.0"))
    end
  end

  def run_second_level(parameters, key, results)
    assert_level(parameters.send(key), results)
    assert_level(parameters[key], results)

    assert_equal(false, parameters.has_param?("0.0.0"))
  end

  def test_file_nil()
    run_test_file_invalid(nil)
  end

  def test_file_does_not_exist()
    run_test_file_invalid("impossible_file_path.yml.impossible")
  end

  def run_test_file_invalid(invalid_value)
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_simple", invalid_path, invalid_path)
      assert_equal("value", parameters.test)
      assert_equal("value", parameters["test"])

      parameters = create_parameters(params_filetype, invalid_path, "params_simple", invalid_path)
      assert_equal("value", parameters.test)
      assert_equal("value", parameters["test"])

      parameters = create_parameters(params_filetype, invalid_path, invalid_path, "params_simple")
      assert_equal("value", parameters.test)
      assert_equal("value", parameters["test"])

      parameters = create_parameters(params_filetype, invalid_path, invalid_path, invalid_path)
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
      parameters = create_parameters(params_filetype, file_path, invalid_path, invalid_path)

      assert_equal("value1", parameters.level1)
      assert_equal("value2", parameters.level2.first)
    end
  end

  def test_restricted_defaults_usage()
    filetypes.each do |params_filetype|
      assert_raise(ArgumentError) do
        results = create_parameters(params_filetype, "params_defaults_at_root", invalid_path, invalid_path)
        puts("Results: #{results.inspect} (Should have thrown!)")
      end
    end

    filetypes.each do |params_filetype|
      assert_raise(ArgumentError) do
        results = create_parameters(params_filetype, "params_defaults_not_at_root", invalid_path, invalid_path)
        puts("Results: #{results.inspect} (Should have thrown!)")
      end
    end
  end

  def test_defaults()
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_simple", invalid_path, invalid_path)
      parameters.defaults = {"test" => "override1", "level" => "new1"}

      assert_equal("value", parameters.test)
      assert_equal("new1", parameters.level)
    end
  end

  def test_empty_file()
    filetypes.each do |params_filetype|
      parameters = create_parameters(params_filetype, "params_empty", invalid_path, invalid_path)
      parameters.defaults = {"test" => "value"}

      assert_equal("value", parameters.test)
    end
  end

  def test_file_not_hash()
    ["boolean", "list"].each do |wrong_type|
      filetypes.each do |params_filetype|
        parameters = create_parameters(params_filetype, "params_#{wrong_type}", invalid_path, invalid_path)
        parameters.defaults = {"test" => "value"}

        assert_equal("value", parameters.test)
      end
    end
  end

  def filetypes()
    @@PARAMS_FILETYPES
  end

  def invalid_path()
    @@INVALID_PATH
  end
end
