require 'pathname'
require 'nugrant/config'
require 'nugrant/parameters'

unless defined?(KeyError)
  class KeyError < IndexError
  end
end

if defined?(Vagrant)
  case
  when defined?(Vagrant::Plugin::V2)
    require 'nugrant/vagrant/v2/plugin'
  when Vagrant::VERSION =~ /1\.0\..*/
    # Nothing to do, v1 plugins are picked by the vagrant_init.rb file
  else
    abort("You are trying to use Nugrant with an unsupported Vagrant version [#{Vagrant::VERSION}]")
  end
end

module Nugrant
  def self.create_parameters(options)
    config = Nugrant::Config.new(options)

    return Nugrant::Parameters.new(config)
  end
end
