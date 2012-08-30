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
  s.description =  <<RUBY
    {
      "type": "RailsEngineGem",
      "name": "SMS Integration",
      "filename": "sms_extension",
      "version": "0.0.1",
      "mount_name": "SmsExtension::Engine",
      "mount_endpoint": "/sms_extension",
      "model_configuration": {
        "included_module": "AP::SmsExtension::Sms",
        "fire_method": "sms_perform",
        "parameters": ["required_configuration"],
        "lifecyle_hooks": {
          "sms_perform": ["after_save", "after_destroy"]
        },
        "required_configuration": {
          "from_phone_number": {
            "type": "String",
            "description": "From phone number."
          },
          "phone_number": {
            "type": "String",
            "description": "Phone number for sending outgoing SMS."
          },
          "outgoing_message_format": {
            "type": "String",
            "description": "The template for the text message..."
          }
        }
      }
    }
RUBY

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "json"
  s.add_dependency "multi_json"
  s.add_dependency "mongoid", ">= 2.4.4"
  s.add_dependency "twilio-ruby"
  s.add_dependency "liquid"
  s.add_dependency "local-env"
  s.add_dependency "faraday"

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
  s.add_development_dependency "ruby-debug19"
end
