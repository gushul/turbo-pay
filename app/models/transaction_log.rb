# == Schema Information
#
# Table name: transaction_logs
#
#  id             :bigint           not null, primary key
#  action         :string           not null
#  details        :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transaction_id :bigint           not null
#
# Indexes
#
#  index_transaction_logs_on_transaction_id  (transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (transaction_id => transactions.id)
#
class TransactionLog < ApplicationRecord
  belongs_to :source, class_name: 'Transaction', foreign_key: 'transaction_id'
  
  
  validates :action, presence: true

  def self.log(transaction, action, details = {})
    create!(
      transaction: transaction,
      action: action,
      details: details
    )
  end
end
