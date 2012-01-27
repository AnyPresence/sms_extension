class OutgoingTextOption < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true, :uniqueness => true
  validates :format, :presence => true
    
end
