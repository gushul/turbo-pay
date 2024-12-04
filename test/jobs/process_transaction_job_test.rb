require "test_helper"

class ProcessTransactionJobTest < ActiveJob::TestCase
  setup do
    @sender = create(:account, balance: 1000, currency: 'USD')
    @recipient = create(:account, balance: 0, currency: 'USD')
    @transaction = create(:transaction,
      sender_account: @sender,
      recipient_account: @recipient,
      amount: 100,
      currency: 'USD',
      status: :pending
    )
  end

  test "enqueues job" do
    assert_enqueued_with(job: ProcessTransactionJob) do
      ProcessTransactionJob.perform_later(@transaction.id)
    end
  end

  test "processes valid transaction" do
    initial_sender_balance = @sender.balance
    initial_recipient_balance = @recipient.balance

    ProcessTransactionJob.perform_now(@transaction.id)
    
    @sender.reload
    @recipient.reload
    @transaction.reload

    assert_equal initial_sender_balance - @transaction.amount, @sender.balance
    assert_equal initial_recipient_balance + @transaction.amount, @recipient.balance
    assert_equal "completed", @transaction.status
  end

  test "handles insufficient funds" do
    @sender.update!(balance: 50)

    ProcessTransactionJob.perform_now(@transaction.id)
    
    @transaction.reload
    assert_equal "failed", @transaction.status
  end

  test "handles missing transaction gracefully" do
    assert_nothing_raised do
      ProcessTransactionJob.perform_now(-1)
    end
  end
end
