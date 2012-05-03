FactoryGirl.define do
  factory :sms_extension_account, :class => SmsExtension::Account do
    application_id "4f204040772c96c4d3000006"
    phone_number "9789445741"
    api_host "http://localhost:5000"
    extension_id "12345"
    
    after_build do |o|
      outgoing_text_option =  Factory.build(:sms_extension_outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
    end
  end
  
  factory :fully_assembled_account, :class => SmsExtension::Account do
    application_id "4f204040772c96c4d3000007"
    phone_number "9789445741"
    api_host "http://localhost:5000"
    extension_id "12345"
    
    after_build do |o|
      outgoing_text_option =  Factory.build(:sms_extension_outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
      
      menu_option = Factory.build(:sms_extension_menu_option)
      o.menu_options << menu_option
    end
  end

end