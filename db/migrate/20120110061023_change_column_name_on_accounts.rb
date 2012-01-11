class ChangeColumnNameOnAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :consumer_phone_number, :consume_phone_number
  end
end
