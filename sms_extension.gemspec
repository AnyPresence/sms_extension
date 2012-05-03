$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sms_extension/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sms_extension"
  s.version     = SmsExtension::VERSION
  s.authors     = ["Anypresence"]
  s.email       = ["fake@fake.local"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_development_dependency "activesupport"
  s.add_development_dependency "json"
  s.add_development_dependency "multi_json"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "mongoid", "2.4.4"
  s.add_development_dependency "devise"
  s.add_development_dependency "faraday"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "haml"
  s.add_development_dependency "hpricot"
  s.add_development_dependency "dynamic_form"
  s.add_development_dependency "simple_form"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "ruby-debug19"
  # s.add_dependency "jquery-rails"
end
