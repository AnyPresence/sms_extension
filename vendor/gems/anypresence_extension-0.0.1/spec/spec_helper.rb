ENV["RAILS_ENV"] = "test"

require 'devise'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'vcr'
require 'database_cleaner'
require 'anypresence_extension'
require 'factory_girl'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

FactoryGirl.find_definitions

Dir[File.expand_path(File.dirname(__FILE__) + "spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  
  config.include Devise::TestHelpers, :type => :controller
    
  # Gives you 'use_vcr_cassette' as a macro
  config.extend VCR::RSpec::Macros
  
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

VCR.config do |c|
  c.stub_with :webmock
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
end

