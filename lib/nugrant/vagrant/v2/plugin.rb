module Nugrant
  module Vagrant
    module V2
      class Plugin < Vagrant.plugin("2")
        name "Nugrant"

        command "foo" do
          require_relative "command/root"

          Nugrant::Vagrant::V2::Command
        end
      end
    end
  end
end

