require 'minitest/autorun'
require 'tmpdir'

require 'nugrant/config'

module Nugrant
  class TestConfig < ::Minitest::Test
    def setup
      @default_param_filename = Nugrant::Config::DEFAULT_PARAMS_FILENAME

      @old_working_dir = Dir.getwd()
      @user_dir = Nugrant::Config.default_user_path()
      @system_dir = Nugrant::Config.default_system_path()

      Dir.chdir(Dir.tmpdir())

      @current_dir = Dir.getwd()
    end

    def teardown
      Dir.chdir(@old_working_dir)

      @old_working_dir = nil
      @current_dir = nil
      @user_dir = nil
      @system_dir = nil
    end

    def test_default_values
      config = Nugrant::Config.new()

      assert_equal(@default_param_filename, config.params_filename())
      assert_equal("#{@current_dir}/#{@default_param_filename}", config.current_path())
      assert_equal("#{@user_dir}/#{@default_param_filename}", config.user_path())
      assert_equal("#{@system_dir}/#{@default_param_filename}", config.system_path())
    end

    def test_custom_params_filename
      config = Nugrant::Config.new({:params_filename => ".customparams"})

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@current_dir}/.customparams", config.current_path())
      assert_equal("#{@user_dir}/.customparams", config.user_path())
      assert_equal("#{@system_dir}/.customparams", config.system_path())
    end

    def test_custom_current_path
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => "#{@user_dir}/.currentcustomparams"
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@user_dir}/.currentcustomparams", config.current_path())
    end

    def test_custom_current_path_without_filename
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => "#{@user_dir}"
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@user_dir}/.customparams", config.current_path())
    end

    def test_custom_current_path_using_callable
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => lambda do ||
          "#{@user_dir}/"
        end
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@user_dir}/.customparams", config.current_path())
    end

    def test_custom_user_path
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :user_path => "#{@system_dir}/.usercustomparams"
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@system_dir}/.usercustomparams", config.user_path())  end

    def test_custom_system_path
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :system_path => "#{@current_dir}/.systemcustomparams"
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@current_dir}/.systemcustomparams", config.system_path())
    end

    def test_custom_all
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => "#{@user_dir}/.currentcustomparams",
        :user_path => "#{@system_dir}/.usercustomparams",
        :system_path => "#{@current_dir}/.systemcustomparams"
      })

      assert_equal(".customparams", config.params_filename())
      assert_equal("#{@user_dir}/.currentcustomparams", config.current_path())
      assert_equal("#{@system_dir}/.usercustomparams", config.user_path())
      assert_equal("#{@current_dir}/.systemcustomparams", config.system_path())
    end

    def test_nil_current
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => nil,
      })

      assert_equal("#{@current_dir}/.customparams", config.current_path())
    end

    def test_nil_user
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :user_path => nil,
      })

      assert_equal("#{@user_dir}/.customparams", config.user_path())
    end

    def test_nil_system
      config = Nugrant::Config.new({
        :params_filename => ".customparams",
        :system_path => nil,
      })

      assert_equal("#{@system_dir}/.customparams", config.system_path())
    end

    def test_invalid_format
      assert_raises(ArgumentError) do
        Nugrant::Config.new({:params_format => :invalid})
      end
    end

    def test_merge
      config1 = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => nil,
      })

      config2 = Nugrant::Config.new({
        :params_filename => ".overrideparams",
        :current_path => "something",
      })

      config3 = config1.merge(config2)

      refute_same(config1, config3)
      refute_same(config2, config3)

      assert_equal(Nugrant::Config.new({
        :params_filename => config2[:params_filename],
        :params_format => config2[:params_format],
        :current_path => config2[:current_path],
        :user_path => config2[:user_path],
        :system_path => config2[:system_path],
        :array_merge_strategy => config2[:array_merge_strategy],
        :key_error => config2[:key_error],
        :parse_error => config2[:parse_error],
      }), config3)
    end

    def test_merge!
      config1 = Nugrant::Config.new({
        :params_filename => ".customparams",
        :current_path => nil,
      })

      config2 = Nugrant::Config.new({
        :params_filename => ".overrideparams",
        :current_path => "something",
      })

      config3 = config1.merge!(config2)

      assert_same(config1, config3)
      refute_same(config2, config3)

      assert_equal(Nugrant::Config.new({
        :params_filename => config2[:params_filename],
        :params_format => config2[:params_format],
        :current_path => config2[:current_path],
        :user_path => config2[:user_path],
        :system_path => config2[:system_path],
        :array_merge_strategy => config2[:array_merge_strategy],
        :key_error => config2[:key_error],
        :parse_error => config2[:parse_error],
      }), config3)
    end
  end
end
