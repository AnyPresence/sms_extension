class AddFieldDisplayKeyToMenuOptions < ActiveRecord::Migration
  def change
    add_column :menu_options, :display_key, :string
  end
end
