# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prot/version'

Gem::Specification.new do |spec|
  spec.name          = "prot"
  spec.version       = Prot::VERSION
  spec.authors       = ["Don Sawtelle"]
  spec.email         = ["don.sawtelle@gmail.com"]
  spec.summary       = %q{Rotate passwords.}
  spec.description   = %q{Rotate passwords.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'capybara', '~> 2.14'
  spec.add_runtime_dependency 'selenium-webdriver', '~> 3.4'
  spec.add_runtime_dependency 'poltergeist', '~> 1.15'

  spec.add_development_dependency "bundler", "~> 1.15"
end
