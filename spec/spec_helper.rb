# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'

require 'factory_girl'
FactoryGirl.find_definitions

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  
  config.include Devise::TestHelpers, :type => :controller
  
  # Setting these variables for testing Twilio
  TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] ||= 'AC8787e2cd208549c7afa37054abd346c7'
  TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] ||= '213fefe477dbeaab4c461bfc2e9a0512'
  TWILIO_FROM_SMS_NUMBER = ENV['TWILIO_FROM_SMS_NUMBER'] ||= '19783194410'
  SHARED_SECRET = ENV['SHARED_SECRET'] ||= '123ccd367902f593b8169d026bd9daad'
end

class Capybara::Server
  def self.manual_host=(value)
    @manual_host = value
  end
  def self.manual_host
    @manual_host ||= 'localhost'
  end

  def url(path)
    if path =~ /^http/
      path
    else
      (Capybara.app_host || "http://#{Capybara::Server.manual_host}:#{port}") + path.to_s
    end
  end
end
