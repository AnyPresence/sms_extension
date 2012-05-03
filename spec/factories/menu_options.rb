FactoryGirl.define do
  factory :sms_extension_menu_option, :class => SmsExtension::MenuOption do
    name 'outage'
    format '{{title}} : {{description}}'
  end
end