require 'nugrant/vagrant/v2/action/auto_export'

module Nugrant
  module Vagrant
    module V2
      module Action
        class << self
          def auto_export
            @auto_export ||= ::Vagrant::Action::Builder.new.tap do |builder|
              builder.use Nugrant::Vagrant::V2::Action::AutoExport
            end
          end
        end
      end
    end
  end
end
