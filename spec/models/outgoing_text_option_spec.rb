require 'spec_helper'

describe OutgoingTextOption do
  before(:each) do 
    @outgoing_text_option = Factory.build(:outgoing_text_option)
  end
  
  it "should know how to build the text message to send" do
    description = "Outage in D.C."
    attr_map = { "description" => description }
    rendered_text = @outgoing_text_option.build_text(attr_map)
    rendered_text.should =~ /#{description}/
  end

end
