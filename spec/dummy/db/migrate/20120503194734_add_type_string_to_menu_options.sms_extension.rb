# This migration comes from sms_extension (originally 20120206223908)
class AddTypeStringToMenuOptions < ActiveRecord::Migration
  def change
    add_column :sms_extension_menu_options, :type, :string
  end
end
