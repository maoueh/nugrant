require 'nugrant/vagrant/v2/action/auto-export'

module Nugrant
  module Vagrant
    module V2
      module Action
        class << self
          # Export in config in file before provision
          def autoExport
            @autoExport ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Nugrant::Vagrant::V2::Action::AutoExport
            end
          end
        end
      end
    end
  end
end