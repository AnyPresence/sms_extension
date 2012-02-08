class AddTypeStringToMenuOptions < ActiveRecord::Migration
  def change
    add_column :menu_options, :type, :string
  end
end
