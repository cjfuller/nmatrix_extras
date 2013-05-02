# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nmatrix_extras/version'

Gem::Specification.new do |spec|
  spec.name          = "nmatrix_extras"
  spec.version       = NmatrixExtras::VERSION
  spec.authors       = ["Colin J. Fuller"]
  spec.email         = ["cjfuller@gmail.com"]
  spec.description   = %q{Extra functions for nmatrix}
  spec.summary       = %q{Adds a number of basic functions present in numpy to nmatrix and adds mapping and reduction.}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "nmatrix", ">= 0.0.3"
end
