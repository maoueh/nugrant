require 'nugrant/config'
require 'test/unit'
require 'tmpdir'

class Nugrant::TestConfig < Test::Unit::TestCase
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

    assert_not_nil("#{@current_dir}/.customparams", config.current_path())
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
    assert_raise(ArgumentError) do
      Nugrant::Config.new({:params_format => :invalid})
    end
  end
end
