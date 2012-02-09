class AddApiTokenStringToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :api_token, :string
  end
end
