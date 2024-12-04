# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_03_040256) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "currency", null: false
    t.decimal "balance", precision: 20, scale: 2, default: "0.0"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "currency"], name: "index_accounts_on_user_id_and_currency", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.string "action", null: false
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_id"], name: "index_transaction_logs_on_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "sender_account_id", null: false
    t.bigint "recipient_account_id", null: false
    t.decimal "amount", precision: 20, scale: 2, null: false
    t.string "currency", null: false
    t.string "status", default: "pending", null: false
    t.string "transaction_type", default: "immediate", null: false
    t.datetime "scheduled_for"
    t.datetime "executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_account_id"], name: "index_transactions_on_recipient_account_id"
    t.index ["scheduled_for"], name: "index_transactions_on_scheduled_for"
    t.index ["sender_account_id"], name: "index_transactions_on_sender_account_id"
    t.index ["status"], name: "index_transactions_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "transaction_logs", "transactions"
  add_foreign_key "transactions", "accounts", column: "recipient_account_id"
  add_foreign_key "transactions", "accounts", column: "sender_account_id"
end
