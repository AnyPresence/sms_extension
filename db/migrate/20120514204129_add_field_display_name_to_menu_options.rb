class AddFieldDisplayNameToMenuOptions < ActiveRecord::Migration
  def change
    add_column :menu_options, :display_name, :string
  end
end
