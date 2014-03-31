require 'pathname'
require 'nugrant/config'
require 'nugrant/parameters'

# 1.8 Compatibility check
unless defined?(KeyError)
  class KeyError < IndexError
  end
end

module Nugrant
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
  else
    raise RuntimeError, "Vagrant [#{Vagrant::VERSION}] is not supported by Nugrant."
  end
end
