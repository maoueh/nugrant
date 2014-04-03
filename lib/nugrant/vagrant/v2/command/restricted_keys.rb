require 'nugrant'
require 'nugrant/vagrant/v2/command/helper'

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

            @env.ui.info("The following keys are restricted, i.e. that method access (`config.user.first`)", :prefix => false)
            @env.ui.info("will not work. If you really want to use a restricted key, use array access ", :prefix => false)
            @env.ui.info("instead (`config.user['local']`).", :prefix => false)
            @env.ui.info("", :prefix => false)

            @env.ui.info("You can run `vagrant user parameters` to check if your config currently defines", :prefix => false)
            @env.ui.info("one or more restricted keys shown below.", :prefix => false)
            @env.ui.info("", :prefix => false)

            restricted_keys = Helper::get_restricted_keys()
            @env.ui.info(restricted_keys.sort().join(", "), :prefix => false)
          end

          def help(parser)
            @env.ui.info(parser.help, :prefix => false)
          end
        end
      end
    end
  end
end
