require 'minitest/autorun'

require 'nugrant'
require 'nugrant/helper/parameters'
require 'nugrant/parameters'

module Nugrant
  class TestParameters < ::Minitest::Test

    @@FORMATS = [:json, :yaml]
    @@INVALID_PATH = "impossible_file_path.yamljson.impossible"

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

    def test_restricted_keys_are_still_accessible
      keys = Helper::Parameters.restricted_keys()
      elements = Hash[
        keys.map do |key|
          [key, "#{key.to_s} - value"]
        end
      ]

      parameters = create_parameters(:json, invalid_path, invalid_path, invalid_path)
      parameters.defaults = elements

      keys.each do |key|
        assert_equal("#{key.to_s} - value", parameters[key.to_s], "parameters[#{key.to_s}]")
        assert_equal("#{key.to_s} - value", parameters[key.to_sym], "parameters[#{key.to_sym}]")
      end
    end

    def test_enumerable_method_insensitive()
      parameters = create_parameters(:json, "params_simple", invalid_path, invalid_path)
      parameters.defaults = {"test" => "override1", :level => :new1}

      assert_equal(1, parameters.count([:test, "value"]))
      assert_equal(1, parameters.count(["test", "value"]))
      assert_equal(0, parameters.count(["test"]))
      assert_equal(0, parameters.count([]))
      assert_equal(0, parameters.count(:a))
      assert_equal(0, parameters.count(nil))

      assert_equal(0, parameters.find_index([:test, "value"]))
      assert_equal(0, parameters.find_index(["test", "value"]))
      assert_equal(nil, parameters.find_index(["test"]))
      assert_equal(nil, parameters.find_index([]))
      assert_equal(nil, parameters.find_index(:a))
      assert_equal(nil, parameters.find_index(nil))
      assert_equal(0, parameters.find_index() { |key, value| key == :test and value == "value" })

      assert_equal(false, parameters.include?([:test, "value"]))
      assert_equal(false, parameters.include?(["test", "value"]))
    end

    def test_hash_method_insensitive()
      parameters = create_parameters(:json, "params_simple", invalid_path, invalid_path)
      parameters.defaults = {"test" => "override1", :level => :new1}

      assert_equal([:test, "value"], parameters.assoc("test"))
      assert_equal([:test, "value"], parameters.assoc(:test))

      # compare_by_identity ?

      parameters.delete("test")
      assert_equal(nil, parameters.assoc("test"))
      assert_equal(nil, parameters.assoc(:test))

      parameters = create_parameters(:json, "params_simple", invalid_path, invalid_path)
      parameters.defaults = {"test" => "override1", :level => :new1}

      assert_equal([[:test, "value"], [:level,  :new1]], parameters.collect {|key, value| [key, value]})

      assert_equal("value", parameters.fetch("test"))
      assert_equal("value", parameters.fetch("test", "default"))
      assert_equal("default", parameters.fetch("unknown", "default"))

      assert_equal(true, parameters.has_key?("test"))
      assert_equal(true, parameters.has_key?(:test))

      assert_equal(true, parameters.include?("test"))
      assert_equal(true, parameters.include?(:test))

      assert_equal(true, parameters.member?("test"))
      assert_equal(true, parameters.member?(:test))

      parameters.store("another", "different")
      assert_equal(true, parameters.member?("another"))
      assert_equal(true, parameters.member?(:another))
    end

    def test_defaults_not_overwritten_on_array_merge_strategy_change
      parameters = create_parameters(:json, "params_array", invalid_path, invalid_path)
      parameters.defaults = {"level1" => {"level2" => ["4", "5", "6"]}}

      parameters.array_merge_strategy = :concat

      assert_equal(["4", "5", "6"], parameters.defaults().level1.level2)
      assert_equal(["1", "2", "3", "4", "5", "6"], parameters.level1.level2)
    end

    def test_merge()
      parameters1 = create_parameters(:json, "params_current_1", invalid_path, invalid_path, {
        "0.1.1" => "default",
        "0.1.0" => "default",
        "0.0.1" => "default",
      })

      parameters2 = create_parameters(:json, "params_current_1", invalid_path, "params_system_1", {
        "0.1.0" => "default_overriden",
      })

      parameters3 = parameters1.merge(parameters2)

      refute_same(parameters1, parameters3)
      refute_same(parameters2, parameters3)

      assert_equal(Nugrant::Parameters, parameters3.class)

      assert_level(parameters3, {
        :'1.1.1' => "current",
        :'1.1.0' => "current",
        :'1.0.1' => "current",
        :'0.1.1' => "system",
        :'1.0.0' => "current",
        :'0.1.0' => "default_overriden",
        :'0.0.1' => "system",
      })
    end

    def test_merge!()
      parameters1 = create_parameters(:json, "params_current_1", invalid_path, invalid_path, {
        "0.1.1" => "default",
        "0.1.0" => "default",
        "0.0.1" => "default",
      })

      parameters2 = create_parameters(:json, "params_current_1", invalid_path, "params_system_1", {
        "0.1.0" => "default_overriden",
      })

      parameters3 = parameters1.merge!(parameters2)

      assert_same(parameters1, parameters3)
      refute_same(parameters2, parameters3)

      assert_equal(Nugrant::Parameters, parameters3.class)

      assert_level(parameters3, {
        :'1.1.1' => "current",
        :'1.1.0' => "current",
        :'1.0.1' => "current",
        :'0.1.1' => "system",
        :'1.0.0' => "current",
        :'0.1.0' => "default_overriden",
        :'0.0.1' => "system",
      })
    end

    def test_merge_with_different_array_merge_strategy()
      parameters1 = create_parameters(:json, "params_array", invalid_path, invalid_path, {
        "level1" => {
          "level2" => ["3", "4", "5"]
        }
      }, :array_merge_strategy => :replace)

      parameters2 = create_parameters(:json, "params_array", invalid_path, invalid_path, {
        "level1" => {
          "level2" => ["3", "6", "7"]
        }
      }, :array_merge_strategy => :concat)

      parameters3 = parameters1.merge(parameters2)

      assert_equal(["1", "2", "3", "3", "6", "7"], parameters3.level1.level2)
    end

    def test_numeric_key_in_yaml_converted_to_symbol()
      parameters = create_parameters(:yaml, "params_numeric_key", invalid_path, invalid_path)

      assert_equal("value1", parameters.servers[:'1'])
    end

    ## Helpers & Assertions

    def create_parameters(format, current_filename, user_filename, system_filename, defaults = {}, options = {})
      extension = case format
        when :json
          "json"
        when :yml, :yaml
          "yml"
        else
          raise ArgumentError, "Format [#{format}] is currently not supported"
      end

      resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../resources/#{format}")

      current_path = "#{resource_path}/#{current_filename}.#{extension}" if current_filename
      user_path = "#{resource_path}/#{user_filename}.#{extension}" if user_filename
      system_path = "#{resource_path}/#{system_filename}.#{extension}" if system_filename

      return Nugrant::Parameters.new(defaults, {
        :format => format,
        :current_path => current_path,
        :user_path => user_path,
        :system_path => system_path,
        :array_merge_strategy => options[:array_merge_strategy]
      })
    end

    def assert_all_access_equal(expected, parameters, key)
      assert_equal(expected, parameters.method_missing(key.to_sym), "parameters.#{key.to_s}")
      assert_equal(expected, parameters[key.to_s], "parameters[#{key.to_s}]")
      assert_equal(expected, parameters[key.to_sym], "parameters[#{key.to_sym}]")
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

    def formats()
      @@FORMATS
    end

    def invalid_path()
      @@INVALID_PATH
    end
  end
end
