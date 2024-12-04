# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  balance      :decimal(20, 2)   default(0.0)
#  currency     :string           not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_accounts_on_user_id               (user_id)
#  index_accounts_on_user_id_and_currency  (user_id,currency) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Account < ApplicationRecord
  self.locking_column = :lock_version

  belongs_to :user
  
  has_many :sent_transactions, 
           class_name: 'Transaction',
           foreign_key: :sender_account_id
  
  has_many :received_transactions,
           class_name: 'Transaction',
           foreign_key: :recipient_account_id

  validates :currency, presence: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, uniqueness: { scope: :user_id }
end
