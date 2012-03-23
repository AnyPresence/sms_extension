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
  s.add_development_dependency "multi_json"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "devise"
  s.add_development_dependency "faraday"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "pg"
  s.add_development_dependency "haml"
  s.add_development_dependency "hpricot"
  s.add_development_dependency "dynamic_form"
  s.add_development_dependency "simple_form"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "ruby-debug19"
  
  #s.rubyforge_project = "anypresence_extension"

  s.files         = `git ls-files`.split("\n")
  s.files.concat(`find lib/anypresence_extension/shared -type f -follow -iname *.rb`.split("\n"))
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
