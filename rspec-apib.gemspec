# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/apib/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-apib"
  spec.version       = RSpec::Apib::VERSION
  spec.authors       = ["Paul Spieker"]
  spec.email         = ["p.spieker@duenos.de"]

  spec.summary       = %q{Generates API Blueprint from request specs}
  spec.homepage      = "https://github.com/spieker/rspec-apib"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '>= 2.2.11'
  spec.add_development_dependency 'rake', '>= 13.0.6'
  spec.add_development_dependency 'guard', '~> 2.16.2'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'pry'
  spec.add_dependency 'rails', (ENV['RAILS_VERSION'] || '>= 6.0.0')
  spec.add_dependency 'rspec-rails', (ENV['RSPEC_VERSION'] || '>= 4.0')
end
