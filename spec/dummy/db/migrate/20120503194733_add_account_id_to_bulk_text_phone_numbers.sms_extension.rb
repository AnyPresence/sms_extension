# This migration comes from sms_extension (originally 20120203200240)
class AddAccountIdToBulkTextPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :sms_extension_bulk_text_phone_numbers, :account_id, :integer
  end
end
