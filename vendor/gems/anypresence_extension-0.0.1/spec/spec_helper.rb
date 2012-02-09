require 'vcr'
require 'webmock'
require 'factory_girl'
FactoryGirl.find_definitions

Dir[File.expand_path(File.dirname(__FILE__) + "spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  
  # Gives you 'use_vcr_cassette' as a macro
  config.extend VCR::RSpec::Macros
end

VCR.config do |c|
  c.stub_with :webmock
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
end

