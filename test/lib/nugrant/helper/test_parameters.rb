require 'minitest/autorun'

require 'nugrant/helper/parameters'

module Nugrant
  module Helper
    class TestParameters < ::Minitest::Test
      def test_restricted_keys_contains_enumerable_ones
        keys = Helper::Parameters.restricted_keys()
        Enumerable.instance_methods.each do |method|
          assert_includes(keys, method, "Restricted keys must include Enumerable method #{method}")
        end
      end
    end
  end
end
