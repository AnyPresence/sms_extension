module SmsExtension
  class Message
    include Mongoid::Document
    include Mongoid::Timestamps
    include SmsExtension::Common
  
    field :sms_message_sid, type: String
    field :account_sid, type: String
    field :body, type: String
    field :from, type: String
    field :to, type: String
  
    validates_presence_of :from, :to
   
    attr_accessible :sms_message_sid, :account_sid, :body, :from, :to
  
    # Strips the phone number prefix such as +1 from +16172345678.
    # Twilio does not currently support toll-free number texting; and texting internationally is in beta.
    def self.strip_phone_number_prefix(phone_number)
      num = phone_number.strip
      num[-10..-1] if num.size >= 10
    end

    # Paginates text if they exceed max_text_length.
    # If the max_text_length is 150, then a 200 char text should have
    # 2 pages where the 1st page ends with "... (1/2)" and the second page
    # should end with "(2/2)"
    def self.paginate_text(message, max_text_length)
      # Make some room for trailing page information
      stop_length = max_text_length - 15
      pages = []
      page_count = 0
      total_page_size = (message.size/Float(max_text_length)).ceil
      remaining_str = message
      while remaining_str.size >= stop_length
        page_content = message[0..stop_length]
        pages[page_count] = page_content
        pages[page_count] << "... (#{page_count+1}/#{total_page_size})"
        page_count = page_count + 1
        remaining_str = message[(stop_length+1)..-1]
      end
      if !remaining_str.empty?
        pages[page_count] = remaining_str
        pages[page_count] << " (#{page_count+1}/#{total_page_size})"
      end

      pages
    end
  
  end
end
