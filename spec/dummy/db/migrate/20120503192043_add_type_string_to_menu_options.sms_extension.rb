# This migration comes from sms_extension (originally 20120206223908)
class AddTypeStringToMenuOptions < ActiveRecord::Migration
  def change
    add_column :menu_options, :type, :string
  end
end
