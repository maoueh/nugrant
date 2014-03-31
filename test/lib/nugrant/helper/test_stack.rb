require 'minitest/autorun'

require 'nugrant/helper/stack'

module Nugrant
  module Helper
    class TestStack < ::Minitest::Test
      def create_stack(options = {})
        pattern = options[:pattern] || "Vagrantfile:%s"
        count = options[:count] || 4

        stack = []
        (0..count).each do |index|
          stack << pattern.gsub("%s", index.to_s())
        end

        stack
      end

      def create_location(name, line)
        resource_path = File.expand_path("#{File.dirname(__FILE__)}/../../../resources/vagrantfiles")

        {:file => "#{resource_path}/#{name}", :line => line}
      end

      def assert_error_location(expected, entry, matcher = nil)
        assert_equal(expected, Stack::extract_error_location(entry, :matcher => matcher), "Not exact error location")
      end

      def assert_error_region(expected, region)
        expected_lines = expected.split("\n")
        region_lines = region.split("\n")

        expected_count = expected_lines.length()
        actual_count = region_lines.length()

        assert_equal(expected_count, actual_count, "Region different line count")

        expected_lines.each_with_index do |expected_line, index|
          assert_equal(expected_line.strip(), region_lines[index].strip(), "Line ##{index} are not equals")
        end
      end

      def test_fetch_error_region_from_location()
        location = create_location("v2.defaults_using_symbol", 4)
        error_region = Stack::fetch_error_region_from_location(location)
        expected_region = <<-EOT
          1:     Vagrant.configure("2") do |config|
          2:       config.user.defaults = {
          3:         :single => 1,
          4:>>       :local => {
          5:           :first => "value1",
          6:           :second => "value2"
          7:         }
          8:       }
        EOT

        assert_error_region(expected_region, error_region)
      end

      def test_fetch_error_region_from_location_custom_prefix()
        location = create_location("v2.defaults_using_symbol", 4)
        error_region = Stack::fetch_error_region_from_location(location, :prefix => "**")
        expected_region = <<-EOT
          **1:     Vagrant.configure(\"2\") do |config|
          **2:       config.user.defaults = {
          **3:         :single => 1,
          **4:>>       :local => {
          **5:           :first => "value1",
          **6:           :second => "value2"
          **7:         }
          **8:       }
        EOT

        assert_error_region(expected_region, error_region)
      end

      def test_fetch_error_region_from_location_custom_width()
        location = create_location("v2.defaults_using_symbol", 4)
        error_region = Stack::fetch_error_region_from_location(location, :width => 2)
        expected_region = <<-EOT
          2:       config.user.defaults = {
          3:         :single => 1,
          4:>>       :local => {
          5:           :first => "value1",
          6:           :second => "value2"
        EOT

        assert_error_region(expected_region, error_region)
      end

      def test_fetch_error_region_from_location_wrong_location()
        location = {:file => nil, :line => nil}
        assert_equal("Unknown", Stack::fetch_error_region_from_location(location))
        assert_equal("Failed", Stack::fetch_error_region_from_location(location, :unknown => "Failed"))

        location = {:file => "Vagrantfile", :line => nil}
        assert_equal("Vagrantfile", Stack::fetch_error_region_from_location(location))

        location = {:file => "NonExistingVagrantfile", :line => 4}
        assert_equal("NonExistingVagrantfile:4", Stack::fetch_error_region_from_location(location))
      end

      def test_find_entry()
        entries = ["First", "Second:", "Third:a", "Fourth:4"]

        assert_equal("Fourth:4", Stack::find_entry(entries))
        assert_equal("Third:a", Stack::find_entry(entries, :matcher => /^(.+):([a-z]+)/))
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
