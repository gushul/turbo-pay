class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :sender_account, null: false, foreign_key: { to_table: :accounts }
      t.references :recipient_account, null: false, foreign_key: { to_table: :accounts }
      t.decimal :amount, precision: 20, scale: 2, null: false
      t.string :currency, null: false
      t.string :status, null: false, default: 'pending'
      t.string :transaction_type, null: false, default: 'immediate'
      t.datetime :scheduled_for
      t.datetime :executed_at

      t.timestamps
    end

    add_index :transactions, :status
    add_index :transactions, :scheduled_for
  end
end
