require 'nugrant'
require 'nugrant/helper/env/exporter'
require 'nugrant/parameters'

EnvExporter = Nugrant::Helper::Env::Exporter

module Nugrant
  module Vagrant
    module V2
      module Action
        class AutoExport
          def initialize(app, env)
            @app = app
            @machine = env[:machine]
            @global_env = @machine.env
            @config = @global_env.vagrantfile.config
            @export_format = @config.user.auto_export
          end
          def call(env)
            unless @export_format.nil? || @export_format == false || @export_format == 0
              options = {:type => :export, :script_path => @config.user.auto_export_script_path}
              Array(@export_format).each { |export_format|
                case
                  when export_format == :script
                    EnvExporter.script_exporter(@config.user.__all, options)
                    env[:ui].info("Configuration exported '#{export_format}'", :prefix => false)
                  when export_format == :autoenv
                    EnvExporter.autoenv_exporter(@config.user.__all, options)
                    env[:ui].info("Configuration exported '#{export_format}'", :prefix => false)
                  else
                    env[:ui].warn("ERROR: Invalid user.auto_export value '#{export_format}'", :prefix => false)
                end
              }
            end
            return @app.call(env)
          end
        end
      end
    end
  end
end