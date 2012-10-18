require 'nugrant/config'
require 'test/unit'
require 'tmpdir'

class Nugrant::TestConfig < Test::Unit::TestCase
  def setup
    @default_param_filename = Nugrant::Config::DEFAULT_PARAMS_FILENAME

    @old_working_dir = Dir.getwd()
    @temp_dir = Dir.tmpdir()
    @home_dir = File.expand_path('~')

    Dir.chdir(@temp_dir)

    @working_dir = Dir.getwd()
  end

  def teardown
    Dir.chdir(@old_working_dir)

    @old_working_dir = nil
    @temp_dir = nil
    @working_dir = nil
    @home_dir = nil
  end

  def test_default_values
    config = Nugrant::Config.new

    assert_equal(@default_param_filename, config.params_filename())
    assert_equal("#{@working_dir}/#{@default_param_filename}", config.local_params_path())
    assert_equal("#{@home_dir}/#{@default_param_filename}", config.global_params_path())
  end

  def test_custom_params_filename
    config = Nugrant::Config.new({:params_filename => ".customparams"})

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@working_dir}/.customparams", config.local_params_path())
    assert_equal("#{@home_dir}/.customparams", config.global_params_path())
  end

  def test_custom_local_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :local_params_path => "#{@home_dir}/.localcustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@home_dir}/.localcustomparams", config.local_params_path())
    assert_equal("#{@home_dir}/.customparams", config.global_params_path())
  end

  def test_custom_global_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :global_params_path => "#{@working_dir}/.globalcustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@working_dir}/.customparams", config.local_params_path())
    assert_equal("#{@working_dir}/.globalcustomparams", config.global_params_path())
  end

  def test_custom_all
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :local_params_path => "#{@home_dir}/.localcustomparams",
      :global_params_path => "#{@working_dir}/.globalcustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@home_dir}/.localcustomparams", config.local_params_path())
    assert_equal("#{@working_dir}/.globalcustomparams", config.global_params_path())
  end
end
