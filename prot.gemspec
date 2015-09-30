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
  spec.add_runtime_dependency 'capybara', '~> 2.5'
  spec.add_runtime_dependency 'selenium-webdriver', '~> 2.47'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "aruba", "~> 0.9"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "minitest"
end
