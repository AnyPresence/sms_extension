require 'spec_helper'

describe "login to manage account", :type => :request do
  before(:each) do
    @user = Factory(:user)
    
    visit new_user_session_path
    fill_in 'user[email]', :with => @user.email
    fill_in 'user[password]', :with => "password"
    
    Rails.logger.info @user.inspect
    
    click_button 'Sign in'
  end
  
  it "should work" do
    @user.should be_nil
  end
  
end