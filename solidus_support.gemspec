# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solidus_support/version'

Gem::Specification.new do |spec|
  spec.name          = "solidus_support"
  spec.version       = SolidusSupport::VERSION
  spec.authors       = ["John Hawthorn"]
  spec.email         = ["john@stembolt.com"]

  spec.summary       = %q{A common functionality for solidus extensions}
  spec.description   = %q{Collection of common functionality for solidus extensions}
  spec.homepage      = "https://solidus.io"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
