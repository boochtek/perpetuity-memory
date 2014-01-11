# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perpetuity/memory/version'

Gem::Specification.new do |spec|
  spec.name          = "perpetuity-memory"
  spec.version       = Perpetuity::Memory::VERSION
  spec.authors       = ["Jamie Gaskins", "Christopher Garvis", "Craig Buchek"]
  spec.email         = ["craig@boochtek.com"]
  spec.description   = %q{In-memory adapter for Perpetuity}
  spec.summary       = %q{In-memory adapter for Perpetuity}
  spec.homepage      = "https://github.com/boochtek/perpetuity-memory"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "perpetuity", "~> 1.0.0.beta3"
end
