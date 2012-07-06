require 'spec_helper'

describe "outages/new" do
  before(:each) do
    assign(:outage, stub_model(Outage).as_new_record)
  end

  it "renders new outage form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => outages_path, :method => "post" do
    end
  end
end
