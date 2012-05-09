require 'spec_helper'

describe SmsExtension::TexterController do
  
  def mock_twilio_client
    twilio_client = double('twilio')
  end
  
  def mock_twilio_account
    twilio_client = double('account')
  end
 
  describe 'perform sms consumption' do
    before(:each) do
      @consume_phone_number = "6178613962"
      @account = FactoryGirl.create(:sms_extension_account, {:consume_phone_number => @consume_phone_number})
    end     
     
    it "should consume and text successfully" do
      SmsExtension::Message.any_instance.stub(:save).and_return(true)
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      #current_account.phone_number = "+19783194410" # a state rejection number
      
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      twilio_account.stub_chain(:sms, :messages, :create).and_return(sms)
      
      post :consume, :SmsMessageSid => '1234', :AccountSid => '1234', :Body => '#1', :From => '+19783194410', :To => @consume_phone_number
      
      parsed_body = JSON.parse(response.body)
      debugger
      parsed_body["success"].should == true
    end
    
    it "should know to send default error message for a phone number it can't find an account for" do
      SmsExtension::Message.any_instance.stub(:save).and_return(true)
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      #subject.current_account.phone_number = "+19783194410"
      
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      
      twilio_account.stub_chain(:sms, :messages, :create).with(any_args())  do |x| 
        x[:body].should == "The extension is not configured for your account." 
      end
      
      # Post with different 'To' phone number
      post :consume, :SmsMessageSid => '1234', :AccountSid => '1234', :Body => '0', :From => '+19783194410', :To => "+16179999999"

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end
  end
 
end