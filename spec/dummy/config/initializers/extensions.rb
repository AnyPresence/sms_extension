AP::SmsExtension::Sms::config_account({:phone_number => "1234", :outgoing_message_format => "howdy {{title}}"})

class ActionController::Base
  def authenticate_admin!
  end
end