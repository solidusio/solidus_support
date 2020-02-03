# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_support/version'

Gem::Specification.new do |s|
  s.name = 'solidus_support'
  s.version = SolidusSupport::VERSION
  s.summary = 'Common runtime helpers for Solidus extensions.'
  s.license = 'BSD-3-Clause'

  s.author = 'John Hawthorn'
  s.email = 'john@stembolt.com'
  s.homepage = 'https://github.com/solidusio/solidus_support'

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', ['>= 5.2', '< 7.0.x']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'solidus_core'
  s.add_development_dependency 'solidus_dev_support'
end
