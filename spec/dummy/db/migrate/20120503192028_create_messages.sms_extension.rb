# This migration comes from sms_extension (originally 20120106035926)
class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :SmsMessageSid
      t.string :AccountSid
      t.string :Body
      t.string :From
      t.string :To

      t.timestamps
    end
  end
end
