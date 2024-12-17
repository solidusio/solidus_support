# frozen_string_literal: true

require_relative 'lib/solidus_support/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_support'
  spec.version = SolidusSupport::VERSION
  spec.author = ['John Hawthorn', 'Solidus Team']
  spec.email = 'contact@solidus.io'

  spec.summary = 'Common runtime helpers for Solidus extensions.'
  spec.homepage = 'https://github.com/solidusio/solidus_support'
  spec.license = 'BSD-3'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio/solidus_support'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio/solidus_support/releases'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'solidus_dev_support'
  spec.add_development_dependency 'omnes', '~> 0.2.2'
end
