# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :accounts, dependent: :destroy
  has_many :sent_transactions, through: :accounts, source: :sent_transactions
  has_many :received_transactions, through: :accounts, source: :received_transactions

  def transactions
    Transaction.where(
      'sender_account_id IN (:account_ids) OR recipient_account_id IN (:account_ids)',
      account_ids: accounts.pluck(:id)
    )
  end

  def balance_for_currency(currency)
    accounts.find_by(currency: currency)&.balance || 0
  end
end
