# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'agwx_grids/version'

Gem::Specification.new do |spec|
  spec.name          = "agwx_grids"
  spec.version       = AgwxGrids::VERSION
  spec.authors       = ["RickWayne"]
  spec.email         = ["fewayne@wisc.edu"]
  spec.description   = %q{UW Soils Ag Weather grid data format (X by Y by DOY) }
  spec.summary       = %q{UW Soils Ag Weather grid data format (X by Y by DOY) }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
