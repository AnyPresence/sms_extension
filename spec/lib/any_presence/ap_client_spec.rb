require 'spec_helper'
require 'any_presence/ap_client'

describe AnyPresence::ApClient do
  before(:each) do
    @ap_client = AnyPresence::ApClient.new

  end
  
  describe "create client" do
    it "should create" do
      @ap_client.should_not be_nil
    end 
  end
  
  
end