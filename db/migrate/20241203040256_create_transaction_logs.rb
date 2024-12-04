class CreateTransactionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_logs do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :action, null: false
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
