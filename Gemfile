source 'https://rubygems.org'

gemspec

group :development do
  vagrant_dependencies = {
    'v1' => {
        'home' => "C:/Users/Matt/.vagrant.d.v1",
        'gem' => Proc.new do
            gem "vagrant", "~> 1.0.5"
        end,
    },
    'v2' => {
        'home' => "C:/Users/Matt/.vagrant.d",
        'gem' => Proc.new do
            gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git"
        end,
    },
  }

  vagrant_plugin_version = ENV['VAGRANT_PLUGIN_VERSION'] || "v2"
  vagrant_dependency = vagrant_dependencies[vagrant_plugin_version]

  ENV['VAGRANT_HOME'] = vagrant_dependency['home']

  vagrant_dependency['gem'].call()
end
