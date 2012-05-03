class ChangeColumnNameOnMessages < ActiveRecord::Migration
  def change
    rename_column :sms_extension_messages, :Body, :body
    rename_column :sms_extension_messages, :From, :from
    rename_column :sms_extension_messages, :To, :to
  end

end
