require 'nugrant/vagrant/v2/action'

module Nugrant
  module Vagrant
    module V2
      class Plugin < ::Vagrant.plugin("2")
        name "Nugrant"
        description <<-DESC
          Plugin to define and use user specific parameters from various location inside your Vagrantfile.
        DESC

        class << self
          def provision(hook)
            hook.before(::Vagrant::Action::Builtin::Provision, Nugrant::Vagrant::V2::Action.auto_export)
          end
        end

        action_hook(:nugrant_provision, :machine_action_up, &method(:provision))
        action_hook(:nugrant_provision, :machine_action_reload, &method(:provision))
        action_hook(:nugrant_provision, :machine_action_provision, &method(:provision))

        command "user" do
          require_relative "command/root"
          Command::Root
        end

        config "user" do
          require_relative "config/user"
          Config::User
        end
      end
    end
  end
end
