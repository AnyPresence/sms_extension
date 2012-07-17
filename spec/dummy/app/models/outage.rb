class Outage
  include Mongoid::Document
  include Mongoid::Timestamps
  include AP::SmsExtension::Sms
  
  # Field definitions
  
  field :"_id", as: :id, type: String

  field :"title", type: String

  field :"num_affected", type: Integer

  field :"latitude", type: Float

  field :"longitude", type: Float
     
  def save
    super
    Rails.logger.info "sending sms. object id: #{self.id}"
    #sms_perform({:from => "16178613962", :to => "16178613962"}, self.class.name, self.id, "there's an outage!! {{title}}")
    sms_perform(self)
  end
  
end