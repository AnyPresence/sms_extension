require 'spec_helper'

describe TexterController do
  include Devise::TestHelpers
  
   before(:all) do
      @account = Account.new

      timestamp = Time.now.to_i
      app_id = 12121212;
      @secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") }
   end
    
   def generate_message
     
   end
    
   describe 'Get text' do
    it "should text without errors" do
      @secure_parameters.should_not be_nil
    end
   end
    
   describe "Get consume" do
    it "should consume" do
      post :consume
      response.should render_template(:new) 
    end
  end
end