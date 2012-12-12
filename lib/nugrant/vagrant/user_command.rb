require 'nugrant'

module Nugrant
  module Vagrant
    class UserCommand < ::Vagrant::Command::Base
      HANDLED_SUBCOMMANDS = [
        "parameters",
      ]

      def initialize(arguments, environment)
        super(arguments, environment)

        @parameters = Nugrant::Parameters.new()
        @options_parser = initialize_parsers()

        @print_help = false
      end

      def initialize_parsers()
        parser = OptionParser.new

        parser.banner = "Usage: vagrant user subcommand [options]"

        parser.on("-h", "--help", "Print this help") do
          @print_help
        end

        parser.separator ""
        parser.separator "Available subcommands:"

        HANDLED_SUBCOMMANDS.each do |subcommand|
          parser.separator "     #{subcommand}"
        end

        return parser
      end

      def execute()
        subcommands = parse_options(@options_parser)
        if not subcommands
          subcommands = ["parameters"]
        end

        subcommands = validate_subcommands(subcommands)
        if not subcommands
          safe_puts(@options_parser.help())
          return
        end

        # At this point, subcommands are valid
        subcommands.each do |subcommand|
          execute_subcommand(subcommand)
        end
      end

      def execute_subcommand(subcommand)
        send(:parameters)
      end

      def parameters()
        parameters = {
          'config' => {
            'user' => @parameters.get_params()
          }
        }

        safe_puts(parameters.to_yaml(:Separator => ""))
      end

      def handled_subcommand?(subcommand)
        return HANDLED_SUBCOMMANDS.find_index(subcommand)
      end

      def validate_subcommands(subcommands)
        subcommands.each do |subcommand|
          if not handled_subcommand?(subcommand)
            puts "Unknown subcommand [#{subcommand}]."
            return nil
          end
        end

        return subcommands
      end
    end
  end
end
