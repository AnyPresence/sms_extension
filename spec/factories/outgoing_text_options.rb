FactoryGirl.define do
  factory :outgoing_text_option do
    name 'outage'
    format "There's a new outage: {{description}}"
    association :account, :factory => :account
  end
end