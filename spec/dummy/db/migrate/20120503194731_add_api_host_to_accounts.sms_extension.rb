# This migration comes from sms_extension (originally 20120131190820)
class AddApiHostToAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_host, :string
  end
end
