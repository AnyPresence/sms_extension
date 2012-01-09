require 'spec_helper'

describe TexterController do
  
  def mock_twilio_client
    twilio_client = double('twilio')
  end
  
  def mock_twilio_account
    twilio_client = double('account')
  end
  
  describe "verify login" do
    before(:each) do
      # create an account for testing
      @account = Factory.build(:account)
      sign_in @account
    end
    
    describe 'validate provision' do
      it "should login successfully" do
        timestamp = Time.now.to_i
        app_id = @account.application_id
        secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") }
      
        post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true    
      end
      
      it "should login unsuccessfully with different application_id" do
        timestamp = Time.now.to_i
        app_id = @account.application_id
        secure_parameters = {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") }
        
        app_id = @account.application_id.to_i + 1;
        app_id = app_id.to_s
        
        post :provision, :application_id => app_id, :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == false 
      end  
      
    end
  end
    
  describe 'perform text' do
    before(:each) do
      # create an account for testing
      @account = Factory.create(:account)
      sign_in @account
    end

    it "should text sucessfully with phone number" do
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      subject.current_account.phone_number = "+16178613962" # a state rejection number
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      twilio_account.stub_chain(:sms,:messages,:create).and_return(sms)
      
      post :text
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end

    it "should text unsuccessfully with json error message when exception is thrown" do
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      subject.current_account.phone_number = "+16178613962" # a state rejection number
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      
      sms = double('sms')
      twilio_account.stub_chain(:sms,:messages,:create).and_raise("Error when trying to text.")
      
      post :text
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == false      
    end
    
    it "should text unsucessfully without phone number" do
      subject.current_account.phone_number = nil;
      post :text
      response.body.should == "Not yet set up!"
    end
         
  end
  
  describe 'perform sms consumption' do
 
    before(:each) do
      # create an account for testing
      @account = Factory.create(:account)
      sign_in @account
    end     
     
    it "should consume without error" do
      post :consume, :sms_message_sid => '1234', :account_sid => '1234', :body => 'test message', :from => '4155992671', :to => '9789445741'
   
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end
  end

end