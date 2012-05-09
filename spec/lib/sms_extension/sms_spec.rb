require 'spec_helper'
require 'sms_extension/sms'

describe SmsExtension::Sms::Consumer do
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  it "should fail when sending without 'from' number" do
    expect { SmsExtension::Sms::Consumer.send_sms }.should raise_error
  end
  
  it "should succeed when sending with correct parameters" do
    twilio_account =double('twilio')
    twilio_client = double('account')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

    twilio_client.stub(:account).and_return(twilio_account)
    twilio_account.stub_chain(:sms, :messages, :create).with(any_args()).and_return(true)
    
    SmsExtension::Sms::Consumer.send_sms(:from => "19786314489", :to => "19789445741", :body => "hello world")
  end
  
  describe "configure" do 
    it "should configure unsuccessfully without parameters" do
      expect { SmsExtension::Sms::config_account }.should raise_error
    end
    
    it "should configure successfully with parameters" do
      SmsExtension::Sms::config_account(:phone_number => "16178613962", :consume_phone_number => "16178613962")
      SmsExtension::Account.all.size.should == 1
    end
    
    it "should configure successfully with menu option parameters for incoming sms" do
      consume_options = [{:option_name => "outage", :option_format => "noo...outage!!"}, {:option_name => "store", :option_format => "stores!!"}]
      SmsExtension::Sms::config_account(:phone_number => "16178613962", :consume_phone_number => "16178613962", :field => "name", :menu_options => consume_options)
      SmsExtension::Account.all.size.should == 1
      SmsExtension::Account.first.menu_options.all.size.should == 
    end
  
  end

end