class AddAccountIdToBulkTextPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :sms_extension_bulk_text_phone_numbers, :account_id, :integer
  end
end
