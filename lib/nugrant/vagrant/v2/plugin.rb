
module Nugrant
  module Vagrant
    module V2
      class Plugin < ::Vagrant.plugin("2")
        name "Nugrant"
        description <<-DESC
          Plugin to define and use user specific parameters from various location inside your Vagrantfile.
        DESC

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

