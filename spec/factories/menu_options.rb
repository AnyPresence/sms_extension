FactoryGirl.define do
  factory :menu_option, :class => SmsExtension::MenuOption do
    option_name 'outage'
    option_format '{{title}} : {{description}}'
  end
end