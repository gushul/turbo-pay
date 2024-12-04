require "test_helper"

class ProcessScheduledTransactionsJobTest < ActiveJob::TestCase
  setup do
    @sender = create(:account, balance: 1000, currency: 'USD')
    @recipient = create(:account, balance: 0, currency: 'USD')
  end

  test "enqueues job" do
    assert_enqueued_with(job: ProcessScheduledTransactionsJob) do
      ProcessScheduledTransactionsJob.perform_later
    end
  end

  test "processes only ready transactions" do
    past_transaction = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient,
      scheduled_for: 1.hour.ago,
      status: :pending
    )

    future_transaction = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient,
      scheduled_for: 1.hour.from_now,
      status: :pending
    )

    completed_transaction = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient,
      scheduled_for: 1.hour.ago,
      status: :completed
    )

    assert_enqueued_jobs 1 do
      ProcessScheduledTransactionsJob.perform_now
    end

    assert_enqueued_with(
      job: ProcessTransactionJob,
      args: [past_transaction.id]
    )
  end

  test "handles empty ready transactions" do
    assert_no_enqueued_jobs do
      ProcessScheduledTransactionsJob.perform_now
    end
  end

  test "continues processing after individual transaction failure" do
    past_transaction1 = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient,
      scheduled_for: 1.hour.ago,
      status: :pending
    )

    past_transaction2 = create(:transaction, :scheduled,
      sender_account: @sender,
      recipient_account: @recipient,
      scheduled_for: 1.hour.ago,
      status: :pending
    )

    ProcessTransactionJob.any_instance.stubs(:perform).with(past_transaction1.id).raises(StandardError)

    assert_enqueued_jobs 2 do
      ProcessScheduledTransactionsJob.perform_now
    end
  end
end
