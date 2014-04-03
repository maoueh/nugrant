require 'nugrant'
require 'nugrant/bag'
require 'nugrant/vagrant/v2/config/user'

module Nugrant
  module Vagrant
    module V2
      module Command
        class Helper
          def self.get_restricted_keys()
            bag_methods = Nugrant::Bag.instance_methods
            parameters_methods = V2::Config::User.instance_methods

            (bag_methods | parameters_methods).map(&:to_s)
          end

          def self.get_used_restricted_keys(hash, restricted_keys)
            keys = []
            hash.each do |key, value|
              keys << key if restricted_keys.include?(key)
              keys += get_used_restricted_keys(value, restricted_keys) if value.kind_of?(Hash)
            end

            keys.uniq
          end
        end
      end
    end
  end
end
