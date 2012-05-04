require 'spec_helper'

describe "outages/edit" do
  before(:each) do
    @outage = assign(:outage, stub_model(Outage))
  end

  it "renders the edit outage form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => outages_path(@outage), :method => "post" do
    end
  end
end
