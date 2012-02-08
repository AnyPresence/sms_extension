class AddAccountIdToBulkTextPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :bulk_text_phone_numbers, :account_id, :integer
  end
end
