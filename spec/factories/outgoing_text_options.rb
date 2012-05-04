FactoryGirl.define do
  factory :outgoing_text_option, :class => SmsExtension::OutgoingTextOption do
    option_name 'outage'
    option_format "There's a new outage: {{description}}"
  end

end