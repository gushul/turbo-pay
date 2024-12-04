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
FactoryBot.define do
  factory :transaction do
    association :sender_account, factory: :account
    association :recipient_account, factory: :account
    amount { 100 }
    currency { 'USD' }
    status { 'pending' } 
    transaction_type { 'immediate' } 
    
    trait :scheduled do
      transaction_type { 'scheduled' }
      scheduled_for { 1.day.from_now }
      after(:build) do |transaction|
        transaction.status = 'pending' if transaction.status.nil?
      end
    end

    trait :completed do
      status { 'completed' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
