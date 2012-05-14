FactoryGirl.define do
  factory :account do
    application_id "4f204040772c96c4d3000006"
    phone_number "9789445741"
    api_host "http://localhost:5000"
    extension_id "12345"
    
    after_build do |o|
      outgoing_text_option =  Factory.build(:outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
    end
  end
  
  factory :fully_assembled_account, :class => Account do
    application_id "4f204040772c96c4d3000007"
    phone_number "9789445741"
    api_host "http://localhost:5000"
    extension_id "12345"
    
    after_build do |o|
      outgoing_text_option =  Factory.build(:outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
      
      menu_option = Factory.build(:menu_option)
      o.menu_options << menu_option
    end
  end
  
  factory :fully_assembled_account_where_outgoing_text_option_has_phone_number, :class => Account do
    application_id "4f204040772c96c4d3000008"
    phone_number "9789445741"
    api_host "http://localhost:5000"
    extension_id "12345"
    
    after_build do |o|
      outgoing_text_option =  Factory.build(:outgoing_text_option_with_phone_number_field)
      o.outgoing_text_options << outgoing_text_option
      
      menu_option = Factory.build(:menu_option)
      o.menu_options << menu_option
    end
  end

end