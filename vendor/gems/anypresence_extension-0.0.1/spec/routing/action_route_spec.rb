require 'spec_helper'

describe "routing lifecycle triggered action", :type => :routing do
  it "should know how to route lifecycle triggered action" do
     { :post => "perform" }.should route_to(:controller  => "settings", :action => "perform")
  end
end