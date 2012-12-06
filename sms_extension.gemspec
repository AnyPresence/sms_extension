$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sms_extension/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sms_extension"
  s.version     = SmsExtension::VERSION
  s.authors     = ["Anypresence"]
  s.email       = ["info@anypresence.com"]
  s.homepage    = "http://www.anypresence.com/"
  s.summary     = ""
  s.description = "SMS integration for apps generated using AnyPresence's solution."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "json"
  s.add_dependency "multi_json"
  s.add_dependency "mongoid", "~> 3.0.6"
  s.add_dependency "twilio-ruby"
  s.add_dependency "liquid"
  s.add_dependency "local-env"
  s.add_dependency "faraday"
  s.add_dependency "kaminari", '~> 0.14.1'

  s.add_dependency "haml"
  s.add_dependency "hpricot"
  s.add_dependency "dynamic_form"
  s.add_dependency "simple_form"
  
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl", "= 3.3.0"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "debugger"
end
