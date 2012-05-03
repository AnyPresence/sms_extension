# This migration comes from sms_extension (originally 20120116192337)
class CreateMenuOptions < ActiveRecord::Migration
  def change
    create_table :menu_options do |t|
      t.string :name
      t.string :format
      t.references :account

      t.timestamps
    end
  end
end
