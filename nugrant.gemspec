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
  gem.summary       = "Library to handle user specific parameters from various location."
  gem.description   = <<-EOF
     Nugrant is a library to easily handle parameters that need to be
     injected into an application via different sources (system, user,
     project, defaults).

     Nugrant can also be directly used as a Vagrant plugin. By activating
     this gem with Vagrant, it will be possible to define user specific
     parameters that will be injected directly into the Vagrantfile. This
     is useful if you need to share a Vagrantfile to multiple developers
     but would like to customize some parameters for each user differently.
  EOF

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test/lib)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "insensitive_hash", "~> 0.0"
  gem.add_dependency "multi_json", "~> 1.0"

  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "minitest", "~> 5.0"
end
