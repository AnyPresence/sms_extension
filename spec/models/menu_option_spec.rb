require 'spec_helper'

describe MenuOption do
  describe "get menu options" do
    before(:each) do 
      @menu_option = Factory.build(:menu_option)
    end
    
    it "should be able to parse the 'format' string" do
      title = "I don't know what happened."
      attr_map = { "title" => title }
      rendered_text = MenuOption::parse_format_string("{{title}} : {{description}}", attr_map)
      rendered_text.should =~ /#{title} : undefined/
    end
  end
end
