require 'spec_helper'

describe "login to manage account", :type => :request do
    
  before(:each) do
    @account = Account.new

    timestamp = Time.now.to_i
    app_id = 12121212;
    @secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("123ccd367902f593b8169d026bd9daad-#{app_id}-#{timestamp}") }

    @user = Factory(:user)
    visit new_user_session_path
    fill_in 'user[email]', :with => @user.email
    fill_in 'user[password]', :with => "password"
    
    click_button 'Sign in'
  end
  
end