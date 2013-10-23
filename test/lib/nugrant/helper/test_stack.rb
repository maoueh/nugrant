require 'test/unit'

require 'nugrant/helper/stack'

module Nugrant
  module Helper
    class TestStack < Test::Unit::TestCase
      def assert_error_location(expected, entry, matcher = nil)
        assert_equal(expected, Stack::extract_error_location(entry, :matcher => matcher))
      end

      def create_stack(options = {})
        pattern = options[:pattern] || "Vagrantfile:%s"
        count = options[:count] || 4

        stack = []
        (0..count).each do |index|
          stack << pattern.gsub("%s", index.to_s())
        end

        stack
      end

      def test_extract_error_location_default_matcher()
        # Matches
        assert_error_location({:file => "/work/irb/workspace.rb", :line => 80}, "/work/irb/workspace.rb:80:in `eval'")
        assert_error_location({:file => "workspace.rb", :line => 80}, "workspace.rb:80:in `eval'")
        assert_error_location({:file => "/work/irb/workspace.rb", :line => 80}, "/work/irb/workspace.rb:80")

        # No match
        assert_error_location({:file => nil, :line => nil}, "/work/irb/workspace.rb?80")
        assert_error_location({:file => nil, :line => nil}, "/work/irb/workspace.rb")
        assert_error_location({:file =>nil, :line => nil}, "")
      end

      def test_extract_error_location_custom_matcher()
        # Matches
        assert_error_location(
          {:file => "/work/Vagrantfile", :line => 80},
          "/work/Vagrantfile:80:in `eval'",
          /(.*Vagrantfile):([0-9]+)/
        )

        assert_error_location(
          {:file => "Vagrantfile", :line => 80},
          "Vagrantfile:80:in `eval'",
          /(.*Vagrantfile):([0-9]+)/
        )

        assert_error_location(
          {:file => "/work/irb/Vagrantfile", :line => 80},
          "/work/irb/Vagrantfile:80",
          /(.*Vagrantfile):([0-9]+)/
        )

        # Partial match
        assert_error_location(
          {:file => "/work/Vagrantfile", :line => nil},
          "/work/Vagrantfile:80:in `eval'",
          /(.*Vagrantfile)/
        )
      end
    end
  end
end
