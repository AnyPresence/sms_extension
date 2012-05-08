require 'spec_helper'
require 'sms_extension/sms'

describe SmsExtension::Sms::Consumer do
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end

end