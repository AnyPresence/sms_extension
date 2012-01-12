class AddPermittedPhoneNumbersOnAccounts < ActiveRecord::Migration
  def up
    add_column :accounts, :permitted_phone_numbers, :text
  end

  def down
    remove_column :accounts, :permitted_phone_numbers, :text
  end
end
