require 'spec_helper'

describe SmsExtension::Message do
  describe "messages exceeding 160 characters" do
    MAX_TEXT_LENGTH = 160
    
    it "should be broken up into pages less than #{MAX_TEXT_LENGTH} each" do
      message_with_200_chars = rand(36**170).to_s(36)
      
      outbound_message = SmsExtension::Message::paginate_text(message_with_200_chars, MAX_TEXT_LENGTH)
      outbound_message.each do |x|
        x.size.should be < MAX_TEXT_LENGTH
      end
    end
  end
end
