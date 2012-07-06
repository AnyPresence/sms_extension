require 'spec_helper'

describe SmsExtension::MenuOption do
  describe "get menu options" do
    before(:each) do 
      @menu_option = FactoryGirl.build(:menu_option)
    end
  
    it "should be able to parse the 'format' string" do
      title = "I don't know what happened."
      attr_map = { "title" => title }
      rendered_text = SmsExtension::MenuOption::parse_format_string("{{title}} : {{description}}", "awesome", attr_map)
      rendered_text.should =~ /#{title}/
    end
  end
  
end
