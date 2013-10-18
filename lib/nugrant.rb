require 'pathname'
require 'nugrant/config'
require 'nugrant/parameters'

unless defined?(KeyError)
  class KeyError < IndexError
  end
end

module Nugrant
  def self.create_parameters(options)
    config = Nugrant::Config.new(options)

    return Nugrant::Parameters.new(config)
  end

  def self.setup_i18n()
    I18n.load_path << File.expand_path("locales/en.yml", Nugrant.source_root)
    I18n.reload!
  end

  def self.source_root
    @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
  end
end

if defined?(Vagrant)
  Nugrant.setup_i18n()

  case
  when defined?(Vagrant::Plugin::V2)
    require 'nugrant/vagrant/v2/plugin'
  when Vagrant::VERSION =~ /1\.0\..*/
    # Nothing to do, v1 plugins are picked by the vagrant_init.rb file
  else
    abort("You are trying to use Nugrant with an unsupported Vagrant version [#{Vagrant::VERSION}]")
  end
end
