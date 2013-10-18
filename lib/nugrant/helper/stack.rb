module Nugrant
  module Helper
    class Stack
      def self.find_error_location(stack, options = {})
        location = find_source_file_location(stack, options)
        return (options[:unknown] || "Unknown") if not location[:file] or not location[:line]

        fetch_context_from_source_file(location, options)
      end

      def self.fetch_context_from_source_file(location, options)
        prefix = options[:prefix] || "   "
        context_width = options[:context_width] || 4
        file = File.new(location[:file], "r")
        line = location[:line]

        context = []
        index = 0
        while (line_string = file.gets())
          index += 1
          next if (line - index).abs > context_width

          line_prefix = "#{prefix}#{index}:"
          line_prefix += (line == index ? ">>   " : "     ")

          context << "#{line_prefix}#{line_string}"
        end

        context.join().chomp()
      rescue
        # TODO: Report error or not ?!? Maybe in Vagrant debug channel
        "#{location[:file]}:#{location[:line]}"
      ensure
        file.close()
      end

      def self.find_source_file_location(stack, options)
        matcher = options[:matcher] || /^(.+):([0-9]+)/
        entry = stack.find do |entry|
          entry =~ matcher
        end

        return {:file => nil, :line => nil} if not entry

        entry =~ matcher
        {:file => $1, :line => $2.to_i()}
      end
    end
  end
end
