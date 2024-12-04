require "test_helper"

class TransactionNotificationJobTest < ActiveJob::TestCase
  setup do
    @sender = create(:account, balance: 1000, currency: 'USD')
    @recipient = create(:account, balance: 0, currency: 'USD')
    @transaction = create(:transaction,
      sender_account: @sender,
      recipient_account: @recipient,
      amount: 100,
      currency: 'USD'
    )
  end

  test "enqueues job" do
    assert_enqueued_with(job: TransactionNotificationJob) do
      TransactionNotificationJob.perform_later(@transaction.id, :completed)
    end
  end

  test "broadcasts completion notification" do
    assert_broadcasts("user_#{@sender.user_id}_transactions", 1) do
      assert_broadcasts("user_#{@sender.user_id}_balance", 1) do
        TransactionNotificationJob.perform_now(@transaction.id, :completed)
      end
    end
  end

  test "broadcasts failure notification" do
    assert_broadcasts("user_#{@sender.user_id}_transactions", 1) do
      TransactionNotificationJob.perform_now(@transaction.id, :failed)
    end
  end
end
