source 'https://rubygems.org'

gemspec

group :development do
  vagrant_dependencies = {
    'v1' => {
      'home' => "~/.vagrant.d.v1",
      'gem' => Proc.new do
        gem "vagrant", "~> 1.0.7"
      end,
    },
    'v2' => {
      'home' => "~/.vagrant.d",
      'gem' => Proc.new do
        gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git", :tag => "v1.3.5"
      end,
    },
  }

  vagrant_plugin_version = ENV['VAGRANT_PLUGIN_VERSION'] || "v2"
  vagrant_dependency = vagrant_dependencies[vagrant_plugin_version]

  ENV['VAGRANT_HOME'] = File.expand_path(vagrant_dependency['home'])

  vagrant_dependency['gem'].call()
end
