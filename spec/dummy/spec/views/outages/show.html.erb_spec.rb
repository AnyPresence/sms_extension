require 'spec_helper'

describe "outages/show" do
  before(:each) do
    @outage = assign(:outage, stub_model(Outage))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
