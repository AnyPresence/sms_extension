require 'anypresence_extension'
require 'spec_helper.rb'

describe AnypresenceExtension::SettingsController do
  def generate_secure_parameters
    timestamp = Time.now.to_i
    app_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") } 
  end
  
  describe "provision" do
    before(:each) do
      ENV['CHAMELEON_HOST'] = "http://localhost:5000"
      @account = Factory.build(:anypresence_extension_account)
    end
    
    it "should know what the extension name is" do
      ENV["EXTENSION_NAME"] = "Some Extension"
      secure_parameters = generate_secure_parameters
      
      controller.stub(:valid_request?).and_return(true)
      post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
      parsed_body = JSON.parse(response.body)
      parsed_body["build_objects"][0]["name"].should == ENV["EXTENSION_NAME"]
    end
    
    it "should know use a default extension name if it's not defined" do
      ENV["EXTENSION_NAME"] = nil
      secure_parameters = generate_secure_parameters
      
      controller.stub(:valid_request?).and_return(true)
      post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
      parsed_body = JSON.parse(response.body)
      parsed_body["build_objects"][0]["name"].should == "Unamed Extension"
    end
    
    it "should login successfully" do
      secure_parameters = generate_secure_parameters
      
      post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true    
    end
  end
end