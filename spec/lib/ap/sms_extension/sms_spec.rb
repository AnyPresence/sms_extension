require 'spec_helper'
require 'ap/sms_extension/sms'

describe AP::SmsExtension::Sms::Consumer do
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  it "should fail when sending without 'from' number" do
    expect { AP::SmsExtension::Sms::Consumer.send_sms }.should raise_error
  end
  
  it "should succeed when sending with correct parameters" do
    setup_twilio
    @twilio_account.stub_chain(:sms, :messages, :create).with(any_args()).and_return(true)
    
    AP::SmsExtension::Sms::Consumer.send_sms(:from => "19786314489", :to => "19789445741", :body => "hello world")
  end
  
  describe "configure" do 
    it "should configure unsuccessfully without parameters" do
      expect { AP::SmsExtension::Sms::config_account }.should raise_error
    end
    
    it "should configure successfully with parameters" do
      AP::SmsExtension::Sms::config_account(:phone_number => "16178613962", :consume_phone_number => "16178613962")
      ::SmsExtension::Account.all.size.should == 1
    end
    
    it "should configure successfully with menu option parameters for incoming sms" do
      consume_options = [{:option_name => "outage", :option_format => "noo...outage!!"}, {:option_name => "store", :option_format => "stores!!"}]
      AP::SmsExtension::Sms::config_account(:phone_number => "16178613962", :consume_phone_number => "16178613962", :field => "name", :menu_options => consume_options)
      ::SmsExtension::Account.all.size.should == 1
      ::SmsExtension::Account.first.menu_options.all.size.should == 2
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
      
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
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
      
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from => "16178613962", :to => "16178613962"}
      consumer.text(options, parsed_json, "outage", format)
    end
    
    it "should use SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER for from number if it's not set on account" do
      ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'] = "1234"
      ::SmsExtension::Account.any_instance.stub(:from_phone_number).and_return(nil)
      thing = double('thing')
      thing.stub(:attributes).and_return({:fake => "fake"})
      options = {}
      AP::SmsExtension::Sms::Consumer.any_instance.stub(:text).and_return(true)
      Class.new.extend(AP::SmsExtension::Sms).sms_perform(thing, options)
      options[:from].should eq(ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'])
    end
    
  end

end