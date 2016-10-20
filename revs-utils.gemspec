# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'revs-utils/version'

Gem::Specification.new do |gem|
  gem.name          = "revs-utils"
  gem.version       = Revs::Utils::VERSION
  gem.authors       = ["Peter Mangiafico"]
  gem.email         = ["pmangiafico@stanford.edu"]
  gem.description   = "Shared methods and functions used by revs-indexer, pre-assembly and bulk metadata loading code."
  gem.summary       = "Shared methods and functions used by revs-indexer, pre-assembly and bulk metadata loading code."
  gem.homepage      = ""
  gem.license       = "All rights reserved, Stanford University."

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.bindir        = 'exe'
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "countries", "~> 1.0"
  gem.add_dependency "rdf"
  gem.add_dependency "actionpack", '>= 4', '< 6'
  gem.add_dependency "chronic"
  gem.add_dependency "rake"

  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "yard"


end
