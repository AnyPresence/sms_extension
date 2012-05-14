class AddFieldToMenuOption < ActiveRecord::Migration
  def change
    add_column :menu_options, :phone_number_field, :string
  end
end
