require 'spec_helper'

describe "outages/index" do
  before(:each) do
    assign(:outages, [
      stub_model(Outage),
      stub_model(Outage)
    ])
  end

  it "renders a list of outages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
