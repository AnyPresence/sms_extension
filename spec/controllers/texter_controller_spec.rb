require 'spec_helper'

describe TexterController do
   
  before(:each) do
    # create an account for testing
    @account = Factory(:account)
   
    sign_in @account
  end
  
  describe 'validate provision' do
    it "should login successfully" do
      timestamp = Time.now.to_i
      app_id = @account.application_id
      secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") }
    
      post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
      Rails.logger.info "param: " + @secure_parameters.inspect
      Rails.logger.info "login: " + response.body.inspect
    end
    
    it "should login unsuccessfully with different application_id" do
      timestamp = Time.now.to_i
      app_id = @account.application_id.to_i + 1;
      app_id = app_id.to_s
      secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") }
    
      post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
      Rails.logger.info "param: " + @secure_parameters.inspect
      Rails.logger.info "login: " + response.body.inspect
    end    
  end
    
  describe 'perform text' do
    #it "should text sucessfully with phone number" do
    #  @account.phone_number = '+19789445741'
      
    #  post :text
    #  parsed_body = JSON.parse(response.body)
    #  parsed_body["success"].should == true
    #end
    
    it "should text unsucessfully without phone number" do
      subject.current_account.phone_number = nil;

      post :text
      response.body.should == "Not yet set up!"
    end
    
  end
    
  describe "Get consume" do
    it "should consume without error" do
      post :consume, :smsMessageSid => '1234', :accountSid => '1234', :body => 'test message', :from => '4155992671', :to => '9789445741'
      messages = Message.all
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end
  end
  
end