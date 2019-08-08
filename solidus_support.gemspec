# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solidus_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'solidus_support'
  spec.version       = SolidusSupport::VERSION
  spec.authors       = ['John Hawthorn']
  spec.email         = ['john@stembolt.com']

  spec.summary       = 'A common functionality for solidus extensions'
  spec.description   = 'Collection of common functionality for solidus extensions'
  spec.homepage      = 'https://solidus.io'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.7'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'solidus_core'
  spec.add_dependency 'capybara-screenshot'
end
