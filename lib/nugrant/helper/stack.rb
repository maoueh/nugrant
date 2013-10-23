module Nugrant
  module Helper
    class Stack
      @@DEFAULT_MATCHER = /^(.+):([0-9]+)/

      def self.fetch_error_region(stack, options = {})
        entry = find_entry(stack, options)
        location = extract_error_location(entry, options)

        return (options[:unknown] || "Unknown") if not location[:file] and not location[:line]
        return location[:file] if not location[:line]

        fetch_error_region_from_location(location, options)
      end

      def self.fetch_error_region_from_location(location, options)
        prefix = options[:prefix] || "   "
        width = options[:width] || 4
        file = File.new(location[:file], "r")
        line = location[:line]

        index = 0

        lines = []
        while (line_string = file.gets())
          index += 1
          next if (line - index).abs > width

          line_prefix = "#{prefix}#{index}:"
          line_prefix += (line == index ? ">>   " : "     ")

          lines << "#{line_prefix}#{line_string}"
        end

        lines.join().chomp()
      rescue
        return (options[:unknown] || "Unknown") if not location[:file] and not location[:line]
        return location[:file] if not location[:line]

        "#{location[:file]}:#{location[:line]}"
      ensure
        file.close() if file
      end

      ##
      # Search a stack list (as simple string array) for the first
      # entry that match the +:matcher+.
      #
      def self.find_entry(stack, options = {})
        matcher = options[:matcher] || @@DEFAULT_MATCHER

        stack.find do |entry|
          entry =~ matcher
        end
      end

      ##
      # Extract error location information from a stack entry using the
      # matcher received in arguments.
      #
      # The usual stack entry format is:
      #   > /home/users/joe/work/lib/ruby.rb:4:Error message
      #
      # This function will extract the file and line information from
      # the stack entry using the matcher. The matcher is expected to
      # have two groups, the first for the file and the second for
      # line.
      #
      # The results is returned in form of a hash with two keys, +:file+
      # for the file information and +:line+ for the line information.
      #
      # If the matcher matched zero group, return +{:file => nil, :line => nil}+.
      # If the matcher matched one group, return +{:file => file, :line => nil}+.
      # If the matcher matched two groups, return +{:file => file, :line => line}+.
      #
      def self.extract_error_location(entry, options = {})
        matcher = options[:matcher] || @@DEFAULT_MATCHER

        result = matcher.match(entry)
        captures = result ? result.captures : []

        {:file => captures[0], :line => captures[1] ? captures[1].to_i() : nil}
      end
    end
  end
end
