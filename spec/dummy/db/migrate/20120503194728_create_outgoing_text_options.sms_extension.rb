# This migration comes from sms_extension (originally 20120126221153)
class CreateOutgoingTextOptions < ActiveRecord::Migration
  def change
    create_table :sms_extension_outgoing_text_options do |t|
      t.string :name
      t.string :format

      t.timestamps
    end
  end
end
