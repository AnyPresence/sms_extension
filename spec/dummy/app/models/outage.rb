class Outage
  include Mongoid::Document
  
  def save
    Rails.logger.info "Saving...#{self.inspect}"
  end
end
