require 'nugrant/config'
require 'test/unit'
require 'tmpdir'

class Nugrant::TestConfig < Test::Unit::TestCase
  def setup
    @default_param_filename = Nugrant::Config::DEFAULT_PARAMS_FILENAME

    @old_working_dir = Dir.getwd()
    @user_dir = File.expand_path('~')

    Dir.chdir(Dir.tmpdir())

    @project_dir = Dir.getwd()
  end

  def teardown
    Dir.chdir(@old_working_dir)

    @old_working_dir = nil
    @project_dir = nil
    @user_dir = nil
    @system_dir = nil
  end

  def test_default_values
    config = Nugrant::Config.new

    assert_equal(@default_param_filename, config.params_filename())
    assert_equal("#{@project_dir}/#{@default_param_filename}", config.project_params_path())
    assert_equal("#{@user_dir}/#{@default_param_filename}", config.user_params_path())
  end

  def test_custom_params_filename
    config = Nugrant::Config.new({:params_filename => ".customparams"})

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@project_dir}/.customparams", config.project_params_path())
    assert_equal("#{@user_dir}/.customparams", config.user_params_path())
  end

  def test_custom_params_filename_after_creation
    config = Nugrant::Config.new({:params_filename => ".vagrantuser"})

    config.params_filename = ".customparams"

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@project_dir}/.customparams", config.project_params_path())
    assert_equal("#{@user_dir}/.customparams", config.user_params_path())
  end

  def test_custom_project_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@user_dir}/.projectcustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@user_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@user_dir}/.customparams", config.user_params_path())
  end

  def test_custom_user_params_path
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :user_params_path => "#{@project_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@project_dir}/.customparams", config.project_params_path())
    assert_equal("#{@project_dir}/.usercustomparams", config.user_params_path())
  end

  def test_custom_all
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@user_dir}/.projectcustomparams",
      :user_params_path => "#{@project_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_equal("#{@user_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@project_dir}/.usercustomparams", config.user_params_path())
  end

  def test_nil_project
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => nil,
      :user_params_path => "#{@user_dir}/.usercustomparams"
    })

    puts "Home: #{@user_dir}"

    assert_equal(".customparams", config.params_filename())
    assert_not_nil(config.project_params_path())
    assert_equal("#{@user_dir}/.customparams", config.user_params_path())
  end

  def test_nil_project
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => nil,
      :user_params_path => "#{@project_dir}/.usercustomparams"
    })

    assert_equal(".customparams", config.params_filename())
    assert_not_nil("#{@project_dir}/.customparams", config.project_params_path())
    assert_equal("#{@project_dir}/.usercustomparams", config.user_params_path())
  end

  def test_nil_user
    config = Nugrant::Config.new({
      :params_filename => ".customparams",
      :project_params_path => "#{@user_dir}/.projectcustomparams",
      :user_params_path => nil
    })

    assert_equal(".customparams", config.params_filename())
    assert_not_nil("#{@user_dir}/.projectcustomparams", config.project_params_path())
    assert_equal("#{@user_dir}/.customparams", config.user_params_path())
  end
end
