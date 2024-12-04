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
FactoryBot.define do
  factory :account do
    user
    currency { 'USD' }
    balance { 1000 }
  end
end
