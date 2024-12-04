class AccountTest < ActiveSupport::TestCase
  test "prevents negative balance" do
    account = create(:account, balance: 100)
    
    assert_raises(ActiveRecord::RecordInvalid) do
      account.update!(balance: -1)
    end
  end

  test "validates currency presence" do
    account = build(:account, currency: nil)
    assert_not account.valid?
  end

  test "handles concurrent updates with optimistic locking" do
    account = create(:account, balance: 1000)
    account_copy = Account.find(account.id)

    account.update!(balance: 900)

    assert_raises(ActiveRecord::StaleObjectError) do
      account_copy.update!(balance: 800)
    end
  end
end
