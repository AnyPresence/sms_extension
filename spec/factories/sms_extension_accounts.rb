FactoryGirl.define do
  factory :sms_extension_account, :class => SmsExtension::Account do
    phone_number "9789445741"
    from_phone_number "9789445741"
    
    after_build do |o|
      outgoing_text_option =  FactoryGirl.build(:outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
    end
  end
  
  factory :fully_assembled_account, :class => SmsExtension::Account do
    phone_number "9789445741"
    
    after_build do |o|
      outgoing_text_option =  FactoryGirl.build(:outgoing_text_option)
      o.outgoing_text_options << outgoing_text_option
      
      menu_option = Factory.build(:menu_option)
      o.menu_options << menu_option
    end
  end

end