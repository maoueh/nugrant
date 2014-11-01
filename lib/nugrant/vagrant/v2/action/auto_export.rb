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
            @config = extract_config(env)
          end
          def extract_config(env)
            return env[:machine].env.vagrantfile.config
          end
          def call(env)
            if @config.user.auto_export
              options = {:type => :export, :script_path => @config.user.auto_export_script_path}
              Array(@config.user.auto_export).each do |format|
                case
                  when format == :script
                    EnvExporter.script_exporter(@config.user.__all, options)
                    env[:ui].info("Configuration exported '#{format}'", :prefix => false)
                  when format == :autoenv
                    EnvExporter.autoenv_exporter(@config.user.__all, options)
                    env[:ui].info("Configuration exported '#{format}'", :prefix => false)
                  else
                    env[:ui].warn("ERROR: Invalid config.user.auto_export value '#{format}'", :prefix => false)
                end
              end
            end
            return @app.call(env)
          end
        end
      end
    end
  end
end
