require 'nugrant'
require 'nugrant/helper/yaml'

module Nugrant
  module Vagrant
    module Command
      class Parameters < ::Vagrant::Command::Base
        def initialize(arguments, environment)
          super(arguments, environment)

          @show_help = false
          @show_system = false
          @show_user = false
          @show_project = false
        end

        def create_parser()
          return OptionParser.new do |parser|
            parser.banner = "Usage: vagrant user parameters [<options>]"
            parser.separator ""

            parser.separator "Available options:"
            parser.separator ""

            parser.on("-h", "--help", "Print this help") do
              @show_help = true
            end

            parser.on("-s", "--system", "Show only system parameters") do
              @show_system = true
            end

            parser.on("-u", "--user", "Show only user parameters") do
               @show_user = true
             end

             parser.on("-p", "--project", "Show only project parameters") do
               @show_project = true
             end

             parser.separator ""
             parser.separator "When no options is provided, the command prints the names and values \n" +
                              "of all parameters that would be available for usage in the Vagrantfile.\n" +
                              "The hierarchy of the parameters is respected, so the final values are\n" +
                              "displayed."

            parser.separator ""
            parser.separator "Notice: For now, defaults directly defined in the Vagrantfile are not \n" +
                             "considered by this command. This is something we would like to fix in \n" +
                             "the near future."
          end
        end

        def execute
          parser = create_parser()
          arguments = parse_options(parser)

          return help(parser) if @show_help

          system() if @show_system
          user() if @show_user
          project() if @show_project

          all() if !@show_system && !@show_user && !@show_project

          return 0
        end

        def help(parser)
          @env.ui.info(parser.help, :prefix => false)
        end

        def system()
          parameters = Nugrant::Parameters.new()

          print_header("System")
          print_parameters(parameters.get_system_params())
        end

        def user()
          parameters = Nugrant::Parameters.new()

          print_header("User")
          print_parameters(parameters.get_user_params())
        end

        def project()
          parameters = Nugrant::Parameters.new()

          print_header("Project")
          print_parameters(parameters.get_project_params())
        end

        def all()
          parameters = Nugrant::Parameters.new()

          print_parameters(parameters.get_params())
        end

        def print_header(kind)
          @env.ui.info("#{kind.capitalize} parameters", :prefix => false)
          @env.ui.info("-----------------------------------------------", :prefix => false)
        end

        def print_parameters(parameters)
          if !parameters || parameters.empty?()
            @env.ui.info(" Empty", :prefix => false)
            @env.ui.info("", :prefix => false)
            return
          end

          data = {
            'config' => {
              'user' => parameters
            }
          }

          string = Nugrant::Helper::Yaml.format(data.to_yaml)
          @env.ui.info(string, :prefix => false)
          @env.ui.info("", :prefix => false)
        end
      end
    end
  end
end
