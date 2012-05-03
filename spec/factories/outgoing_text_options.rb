FactoryGirl.define do
  factory :outgoing_text_option, :class => SmsExtension::OutgoingTextOption do
    name 'outage'
    format "There's a new outage: {{description}}"
  end

end