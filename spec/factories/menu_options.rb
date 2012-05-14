FactoryGirl.define do
  factory :menu_option do
    name 'outage'
    format '{{title}} : {{description}}'
  end
  
  factory :menu_option_with_display_name do
    name 'outage'
    display_text 'outage we go...'
    format '{{title}} : {{description}}'
  end
end