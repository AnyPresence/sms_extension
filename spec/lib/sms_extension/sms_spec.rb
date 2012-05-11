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
    setup_twilio
    @twilio_account.stub_chain(:sms, :messages, :create).with(any_args()).and_return(true)
    
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
      SmsExtension::Account.first.menu_options.all.size.should == 2
    end
  
  end
  
  describe "text" do
    before(:each) do
      @account = FactoryGirl.create(:sms_extension_account)
    end
    
    def params
      %q({"title":"Cleveland Abbe House","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"})
    end
    
    it "should know how to text" do
      setup_twilio
      format = "hello world" 
      @twilio_account.stub_chain(:sms, :messages, :create).with do |arg|
        arg[:body].should eq(format)
      end
      
      consumer = SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from => "16178613962", :to => "16178613962"}
      consumer.text(options, parsed_json, "outage", format)
    end
    
    it "should know how to text with interpolated variables" do
      setup_twilio
      format = "hello, {{title}}" 
      @twilio_account.stub_chain(:sms, :messages, :create).with do |arg|
        arg[:body].should eq("hello, Cleveland Abbe House")
      end
      
      consumer = SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from => "16178613962", :to => "16178613962"}
      consumer.text(options, parsed_json, "outage", format)
    end
    
  end

end