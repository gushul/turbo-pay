class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency, null: false
      t.decimal :balance, precision: 20, scale: 2, default: 0
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end

    add_index :accounts, [:user_id, :currency], unique: true
  end
end
