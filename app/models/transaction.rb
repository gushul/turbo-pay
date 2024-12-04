# == Schema Information
#
# Table name: transactions
#
#  id                   :bigint           not null, primary key
#  amount               :decimal(20, 2)   not null
#  currency             :string           not null
#  executed_at          :datetime
#  scheduled_for        :datetime
#  status               :string           default(NULL), not null
#  transaction_type     :string           default(NULL), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  recipient_account_id :bigint           not null
#  sender_account_id    :bigint           not null
#
# Indexes
#
#  index_transactions_on_recipient_account_id  (recipient_account_id)
#  index_transactions_on_scheduled_for         (scheduled_for)
#  index_transactions_on_sender_account_id     (sender_account_id)
#  index_transactions_on_status                (status)
#
# Foreign Keys
#
#  fk_rails_...  (recipient_account_id => accounts.id)
#  fk_rails_...  (sender_account_id => accounts.id)
#
class Transaction < ApplicationRecord
  belongs_to :sender_account, class_name: 'Account'
  belongs_to :recipient_account, class_name: 'Account'
  has_many :logs, class_name: 'TransactionLog', foreign_key: 'transaction_id'

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true
  validates :transaction_type, presence: true

  enum status: {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }

  enum transaction_type: {
    immediate: 'immediate',
    scheduled: 'scheduled'
  }

  scope :scheduled, -> { where(transaction_type: :scheduled) }
  scope :pending, -> { where(status: :pending) }
  scope :ready_for_execution, -> { scheduled.pending.where('scheduled_for <= ?', Time.current) }

  def can_cancel?
    scheduled = scheduled?
    is_pending = pending?
    is_future = scheduled_for.present? && scheduled_for > Time.current

    Rails.logger.debug "Scheduled: #{scheduled}, Pending: #{is_pending}, Future: #{is_future}"
    Rails.logger.debug "Status: #{status}, Type: #{transaction_type}, Scheduled for: #{scheduled_for}"

    scheduled && is_pending && is_future
  end
 end
