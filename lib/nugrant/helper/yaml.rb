module Nugrant
  module Helper
    class Yaml
      def self.format(string, options = {})
        lines =  string.send(string.respond_to?(:lines) ? :lines : :to_s).to_a
        lines = lines.drop(1)

        if options[:indent]
          indent_text = " " * options[:indent]
          lines = lines.map do |line|
            indent_text + line
          end
        end

        return lines.join("")
      end
    end
  end
end
