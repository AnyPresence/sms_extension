class CreateMenuOptions < ActiveRecord::Migration
  def change
    create_table :sms_extension_menu_options do |t|
      t.string :name
      t.string :format
      t.references :account

      t.timestamps
    end
  end
end
