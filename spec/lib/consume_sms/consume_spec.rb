require 'spec_helper'
require 'consume_sms/consume'

describe ConsumeSms::Consumer do
  before(:each) do
    account = Factory.build(:account)
    @consumer = ConsumeSms::Consumer.new(account.application_id, account.field_name)
  end 

  describe "connect to api" do
    it "should raise error when redirecting" do
      response = Net::HTTPRedirection.new(nil, nil, nil)
      ConsumeSms.stub(:connect_to_api).with(any_args()).and_return(response)
      
      message = Message.new
      text_message_options = {"#1" => "cow"}
      message.body = "#1"
      expect {@consumer.consume_sms(message, text_message_options)}.should raise_error(ConsumeSms::GeneralTextMessageNotifierException)
    end
  end
  
  describe "liquidify" do
    
  end
  
end