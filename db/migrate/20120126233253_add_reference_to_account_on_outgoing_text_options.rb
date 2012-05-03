class AddReferenceToAccountOnOutgoingTextOptions < ActiveRecord::Migration
  def change
    add_column :sms_extension_outgoing_text_options, :account_id, :integer
  end
end
