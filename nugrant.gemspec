# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nugrant/version'

Gem::Specification.new do |gem|
  gem.name          = "nugrant"
  gem.version       = Nugrant::VERSION
  gem.authors       = ["Matthieu Vachon"]
  gem.email         = ["matthieu.o.vachon@gmail.com"]
  gem.homepage      = "https://github.com/maoueh/nugrant"
  gem.summary       = "Vagrant plugin to enable user specific configuration parameters."
  gem.description   = <<-EOF
     This gem is in fact a Vagrant pluging. By installing this gem, it will be
     possible to define user specific configuration files that will be merge
     directly into the Vagrant configuration. This is usefull if you need to
     share a Vagrantfile to multiple developers but would like to customize
     some parameters for each users differently.
  EOF

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "deep_merge", "~> 1.0.0"

  gem.add_development_dependency "rake", "~> 0.9.0"
  gem.add_development_dependency "vagrant", "~> 1.0.0"
end
