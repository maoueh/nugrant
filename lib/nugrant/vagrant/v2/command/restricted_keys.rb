require 'nugrant'
require 'nugrant/vagrant/v2/config/user'

module Nugrant
  module Vagrant
    module V2
      module Command
        class RestrictedKeys < ::Vagrant.plugin("2", :command)
          def initialize(arguments, environment)
            super(arguments, environment)

            @show_help = false
          end

          def create_parser()
            return OptionParser.new do |parser|
              parser.banner = "Usage: vagrant user restricted-keys"
              parser.separator ""

              parser.separator "Available options:"
              parser.separator ""

              parser.on("-h", "--help", "Print this help") do
                @show_help = true
              end

               parser.separator ""
               parser.separator "Prints keys that cannot be accessed using the method access syntax\n" +
                                "(`config.user.local`). Use array access syntax (`config.user['local']`)\n" +
                                "if you really want to use of the restricted keys\n"
            end
          end

          def execute
            parser = create_parser()
            arguments = parse_options(parser)

            return help(parser) if @show_help

            methods = V2::Config::User.instance_methods
            methods.sort!

            @env.ui.info(methods.join(", "), :prefix => false)
          end

          def help(parser)
            @env.ui.info(parser.help, :prefix => false)
          end
        end
      end
    end
  end
end
