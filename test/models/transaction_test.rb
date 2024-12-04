require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  def setup
    @sender = create(:account, balance: 1000, currency: 'USD')
    @recipient = create(:account, balance: 0, currency: 'USD')
  end

  test "should be valid with valid attributes" do
    transaction = Transaction.new(
      sender_account: @sender,
      recipient_account: @recipient,
      amount: 100,
      currency: 'USD',
      status: :pending,
      transaction_type: :immediate
    )
    assert transaction.valid?
  end

  test "should require sender_account" do
    transaction = Transaction.new(
      recipient_account: @recipient,
      amount: 100,
      currency: 'USD'
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:sender_account], "must exist"
  end

  test "should require recipient_account" do
    transaction = Transaction.new(
      sender_account: @sender,
      amount: 100,
      currency: 'USD'
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:recipient_account], "must exist"
  end

  test "should require positive amount" do
    transaction = Transaction.new(
      sender_account: @sender,
      recipient_account: @recipient,
      amount: -100,
      currency: 'USD'
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:amount], "must be greater than 0"
  end

  test "should require currency" do
    transaction = Transaction.new(
      sender_account: @sender,
      recipient_account: @recipient,
      amount: 100
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:currency], "can't be blank"
  end

  test "scheduled scope returns only scheduled transactions" do
    immediate = create(:transaction, transaction_type: :immediate)
    scheduled = create(:transaction, transaction_type: :scheduled)
    
    assert_includes Transaction.scheduled, scheduled
    assert_not_includes Transaction.scheduled, immediate
  end

  test "ready_for_execution scope returns only pending scheduled transactions in the past" do
    past_transaction = create(:transaction, 
      transaction_type: :scheduled,
      status: :pending,
      scheduled_for: 1.hour.ago
    )
    future_transaction = create(:transaction,
      transaction_type: :scheduled,
      status: :pending,
      scheduled_for: 1.hour.from_now
    )
    completed_transaction = create(:transaction,
      transaction_type: :scheduled,
      status: :completed,
      scheduled_for: 1.hour.ago
    )

    ready_transactions = Transaction.ready_for_execution
    
    assert_includes ready_transactions, past_transaction
    assert_not_includes ready_transactions, future_transaction
    assert_not_includes ready_transactions, completed_transaction
  end

  test "can_cancel returns true for pending scheduled transactions in the future" do
    transaction = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient
    )

    assert_equal 'scheduled', transaction.transaction_type
    assert_equal 'pending', transaction.status
    assert transaction.scheduled_for > Time.current
    
    assert transaction.can_cancel?, 
      "Transaction should be cancellable with type: #{transaction.transaction_type}, " \
      "status: #{transaction.status}, scheduled_for: #{transaction.scheduled_for}"
  end

  test "can_cancel? returns false for immediate transactions" do
    transaction = create(:transaction, transaction_type: :immediate)
    assert_not transaction.can_cancel?
  end

  test "can_cancel? returns false for completed transactions" do
    transaction = create(:transaction, :scheduled, :completed)
    assert_not transaction.can_cancel?
  end

  test "can_cancel? returns false for past scheduled transactions" do
    transaction = create(:transaction, :scheduled, scheduled_for: 1.hour.ago)
    assert_not transaction.can_cancel?
  end
end

