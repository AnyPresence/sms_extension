FactoryGirl.define do
  factory :menu_option do
    name 'outage'
    format '{{title}} : {{description}}'
    association :account, :factory => :account
  end
end