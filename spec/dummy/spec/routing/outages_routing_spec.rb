require "spec_helper"

describe OutagesController do
  describe "routing" do

    it "routes to #index" do
      get("/outages").should route_to("outages#index")
    end

    it "routes to #new" do
      get("/outages/new").should route_to("outages#new")
    end

    it "routes to #show" do
      get("/outages/1").should route_to("outages#show", :id => "1")
    end

    it "routes to #edit" do
      get("/outages/1/edit").should route_to("outages#edit", :id => "1")
    end

    it "routes to #create" do
      post("/outages").should route_to("outages#create")
    end

    it "routes to #update" do
      put("/outages/1").should route_to("outages#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/outages/1").should route_to("outages#destroy", :id => "1")
    end

  end
end
