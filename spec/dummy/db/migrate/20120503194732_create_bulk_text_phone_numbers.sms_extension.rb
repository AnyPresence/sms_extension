# This migration comes from sms_extension (originally 20120202143043)
class CreateBulkTextPhoneNumbers < ActiveRecord::Migration
  def change
    create_table :sms_extension_bulk_text_phone_numbers do |t|
      t.string :name
      t.string :format

      t.timestamps
    end
  end
end
