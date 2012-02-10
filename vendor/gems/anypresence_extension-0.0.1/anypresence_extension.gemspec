# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "anypresence_extension/version"

Gem::Specification.new do |s|
  s.name        = "anypresence_extension"
  s.version     = AnypresenceExtension::VERSION
  s.authors     = ["Anypresence"]
  s.email       = ["fake@fake.local"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  
  s.add_development_dependency "activesupport"
  s.add_development_dependency "json"
  s.add_development_dependency "rspec"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  
  #s.rubyforge_project = "anypresence_extension"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
