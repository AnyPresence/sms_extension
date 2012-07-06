FactoryGirl.define do
  factory :menu_option, :class => SmsExtension::MenuOption do
    option_name 'outage'
    option_format '{{title}} : {{description}}'
  end
  
  factory :menu_option_with_display_name do
    name 'outage'
    display_text 'outage we go...'
    format '{{title}} : {{description}}'
  end
end