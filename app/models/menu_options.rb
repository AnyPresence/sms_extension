class MenuOptions < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true
  validates :format, :presence => true
end
