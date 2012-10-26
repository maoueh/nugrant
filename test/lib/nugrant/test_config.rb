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
    assert_equal("#{@working_dir}/#{@default_param_filename}", config.project_params_path())
    assert_equal("#{@home_dir}/#{@default_param_filename}", config.user_params_path())
  end

  def test_custom_params_filename
    config = Nugrant::Config.new({:params_filename => ".customparams"})

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@working_dir}/.customparams", config.project_params_path())
    assert_equal("#{@home_dir}/.customparams", config.user_params_path())
  end

  def test_custom_project_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@home_dir}/.projectcustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@home_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@home_dir}/.customparams", config.user_params_path())
  end

  def test_custom_user_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :user_params_path => "#{@working_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@working_dir}/.customparams", config.project_params_path())
    assert_equal("#{@working_dir}/.usercustomparams", config.user_params_path())
  end

  def test_custom_all
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@home_dir}/.projectcustomparams",
      :user_params_path => "#{@working_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@home_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@working_dir}/.usercustomparams", config.user_params_path())
  end

  def test_nil_project
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => nil,
      :user_params_path => "#{@home_dir}/.usercustomparams"
    })

    puts "Home: #{@home_dir}"

    assert_equal(".customparams", config.params_filename())
    assert_not_nil(config.project_params_path())
    assert_equal("#{@home_dir}/.customparams", config.user_params_path())
  end

  def test_nil_project
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => nil,
      :user_params_path => "#{@working_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_not_nil("#{@working_dir}/.customparams", config.project_params_path())
    assert_equal("#{@working_dir}/.usercustomparams", config.user_params_path())
  end

  def test_nil_user
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@home_dir}/.projectcustomparams",
      :user_params_path => nil
    })

    assert_equal(".customparams", config.params_filename())
    assert_not_nil("#{@home_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@home_dir}/.customparams", config.user_params_path())
  end
end
