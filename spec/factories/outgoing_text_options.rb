FactoryGirl.define do
  factory :outgoing_text_option, :class => SmsExtension::OutgoingTextOption do
    option_name 'outage'
    option_format "There's a new outage: {{description}}"
  end
  
  factory :outgoing_text_option_with_phone_number_field, :class => OutgoingTextOption do
    name 'incomingcontact'
    phone_number_field "{{phone_number}}"
    format "There's a new outage: {{description}}"
  end

end