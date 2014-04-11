require 'minitest/autorun'

require 'nugrant'
require 'nugrant/parameters'

module Nugrant
  class TestParameters < ::Minitest::Test

    @@FORMATS = [:json, :yaml]
    @@INVALID_PATH = "impossible_file_path.yamljson.impossible"

    def create_parameters(format, current_filename, user_filename, system_filename)
      extension = case
        when format = :json
          "json"
        when format = :yaml
          "yml"
        else
          raise ArgumentError, "Format [#{format}] is currently not supported"
      end

      resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../resources/#{format}")

      current_path = "#{resource_path}/#{current_filename}.#{extension}" if current_filename
      user_path = "#{resource_path}/#{user_filename}.#{extension}" if user_filename
      system_path = "#{resource_path}/#{system_filename}.#{extension}" if system_filename

      return Nugrant::Parameters.new({
        :format => format,
        :current_path => current_path,
        :user_path => user_path,
        :system_path => system_path,
      })
    end

    def assert_all_access_equal(expected, parameters, key)
      assert_equal(expected, parameters.method_missing(key.to_sym), "parameters.#{key.to_sym.inspect}")
      assert_equal(expected, parameters[key.to_s], "parameters[#{key.to_s.inspect}]")
      assert_equal(expected, parameters[key.to_sym], "parameters[#{key.to_sym.inspect}]")
    end

    def assert_level(parameters, results)
      results.each do |key, value|
        assert_all_access_equal(value, parameters, key)
      end

      assert_key_error(parameters, "0.0.0")
    end

    def assert_key_error(parameters, key)
      assert_raises(KeyError) do
        parameters[key]
      end
    end

    def test_params_level_1()
      formats.each do |format|
        parameters = create_parameters(format, "params_current_1", "params_user_1", "params_system_1")

        assert_level(parameters, {
          :'1.1.1' => "current",
          :'1.1.0' => "current",
          :'1.0.1' => "current",
          :'0.1.1' => "user",
          :'1.0.0' => "current",
          :'0.1.0' => "user",
          :'0.0.1' => "system",
        })
      end
    end

    def test_params_level_2()
      formats.each do |format|
        parameters = create_parameters(format, "params_current_2", "params_user_2", "params_system_2")

        run_second_level(parameters, :'1.1.1', {
          :'1.1.1' => "current",
          :'1.1.0' => "current",
          :'1.0.1' => "current",
          :'0.1.1' => "user",
          :'1.0.0' => "current",
          :'0.1.0' => "user",
          :'0.0.1' => "system",
        })

        run_second_level(parameters, :'1.1.0', {
          :'1.1.1' => "current",
          :'1.1.0' => "current",
          :'1.0.1' => "current",
          :'0.1.1' => "user",
          :'1.0.0' => "current",
          :'0.1.0' => "user",
        })

        run_second_level(parameters, :'1.0.1', {
          :'1.1.1' => "current",
          :'1.1.0' => "current",
          :'1.0.1' => "current",
          :'0.1.1' => "system",
          :'1.0.0' => "current",
          :'0.0.1' => "system",
        })

        run_second_level(parameters, :'0.1.1', {
          :'1.1.1' => "user",
          :'1.1.0' => "user",
          :'1.0.1' => "system",
          :'0.1.1' => "user",
          :'0.1.0' => "user",
          :'0.0.1' => "system",
        })

        run_second_level(parameters, :'1.0.0', {
          :'1.1.1' => "current",
          :'1.1.0' => "current",
          :'1.0.1' => "current",
          :'1.0.0' => "current",
        })

        run_second_level(parameters, :'0.1.0', {
          :'1.1.1' => "user",
          :'1.1.0' => "user",
          :'0.1.1' => "user",
          :'0.1.0' => "user",
        })

        run_second_level(parameters, :'0.0.1', {
          :'1.1.1' => "system",
          :'1.0.1' => "system",
          :'0.1.1' => "system",
          :'0.0.1' => "system",
        })

        assert_key_error(parameters, :'0.0.0')
      end
    end

    def run_second_level(parameters, key, results)
      assert_level(parameters.send(key), results)
      assert_level(parameters[key], results)

      assert_key_error(parameters, :'0.0.0')
    end

    def test_params_array()
      file_path = "params_array"
      formats.each do |format|
        parameters = create_parameters(format, file_path, invalid_path, invalid_path)

        assert_equal(["1", "2", "3"], parameters[:level1][:level2])
      end
    end

    def test_file_nil()
      run_test_file_invalid(nil)
    end

    def test_file_does_not_exist()
      run_test_file_invalid("impossible_file_path.yml.impossible")
    end

    def run_test_file_invalid(invalid_value)
      formats.each do |format|
        parameters = create_parameters(format, "params_simple", invalid_path, invalid_path)
        assert_all_access_equal("value", parameters, "test")

        parameters = create_parameters(format, invalid_path, "params_simple", invalid_path)
        assert_all_access_equal("value", parameters, "test")

        parameters = create_parameters(format, invalid_path, invalid_path, "params_simple")
        assert_all_access_equal("value", parameters, "test")

        parameters = create_parameters(format, invalid_path, invalid_path, invalid_path)
        assert(parameters)
      end
    end

    def test_params_windows_eol()
      run_test_params_eol("params_windows_eol")
    end

    def test_params_unix_eol()
      run_test_params_eol("params_unix_eol")
    end

    def run_test_params_eol(file_path)
      formats.each do |format|
        parameters = create_parameters(format, file_path, invalid_path, invalid_path)

        assert_all_access_equal("value1", parameters, 'level1')
        assert_all_access_equal("value2", parameters['level2'], 'first')
      end
    end

    def test_restricted_defaults_usage()
      formats.each do |format|
        parameters = create_parameters(format, "params_defaults_at_root", invalid_path, invalid_path)

        assert_all_access_equal("value", parameters, :defaults)
      end

      formats.each do |format|
        parameters = create_parameters(format, "params_defaults_not_at_root", invalid_path, invalid_path)

        assert_all_access_equal("value", parameters.level, :defaults)
      end
    end

    def test_defaults()
      formats.each do |format|
        parameters = create_parameters(format, "params_simple", invalid_path, invalid_path)
        parameters.defaults = {:test => "override1", :level => "new1"}

        assert_all_access_equal("value", parameters, 'test')
        assert_all_access_equal("new1", parameters, 'level')
      end
    end

    def test_empty_file()
      formats.each do |format|
        parameters = create_parameters(format, "params_empty", invalid_path, invalid_path)
        parameters.defaults = {:test => "value"}

        assert_all_access_equal("value", parameters, 'test')
      end
    end

    def test_file_not_hash()
      ["boolean", "list"].each do |wrong_type|
        formats.each do |format|
          parameters = create_parameters(format, "params_#{wrong_type}", invalid_path, invalid_path)
          parameters.defaults = {:test => "value"}

          assert_all_access_equal("value", parameters, 'test')
        end
      end
    end

    def test_nil_values()
      formats.each do |format|
        parameters = create_parameters(format, "params_user_nil_values", invalid_path, invalid_path)
        parameters.defaults = {:nil => "Not nil", :deep => {:nil => "Not nil", :deeper => {:nil => "Not nil"}}}

        assert_all_access_equal("Not nil", parameters[:deep][:deeper], :nil)
        assert_all_access_equal("Not nil", parameters[:deep], :nil)
        assert_all_access_equal("Not nil", parameters, :nil)
      end

      formats.each do |format|
        parameters = create_parameters(format, "params_user_nil_values", invalid_path, invalid_path)

        assert_all_access_equal(nil, parameters[:deep][:deeper], :nil)
        assert_all_access_equal(nil, parameters[:deep], :nil)
        assert_all_access_equal(nil, parameters, :nil)
      end
    end

    def formats()
      @@FORMATS
    end

    def invalid_path()
      @@INVALID_PATH
    end
  end
end
