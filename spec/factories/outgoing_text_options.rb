FactoryGirl.define do
  factory :outgoing_text_option do
    name 'outage'
    format "There's a new outage: {{description}}"
  end

end