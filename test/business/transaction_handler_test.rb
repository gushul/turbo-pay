require 'test_helper'

class TransactionHandlerTest < ActiveSupport::TestCase
  setup do
    @sender = create(:account, balance: 1000, currency: 'USD')
    @recipient = create(:account, balance: 0, currency: 'USD')
    @handler = TransactionHandler.new
  end

  test "creates immediate transaction successfully" do
    transaction = @handler.create(
      sender: @sender,
      recipient: @recipient,
      amount: 100,
      currency: 'USD'
    )

    assert transaction.persisted?
    assert_equal 'immediate', transaction.transaction_type
    assert_equal 'completed', transaction.status

    assert_equal 900, @sender.reload.balance     # 1000 - 100
    assert_equal 100, @recipient.reload.balance  # 0 + 100
  end

  test "prevents negative balance" do
    assert_raises(TransactionHandler::InsufficientFundsError) do
      @handler.create(
        sender: @sender,
        recipient: @recipient,
        amount: 2000,
        currency: 'USD'
      )
    end
  end

  test "handles concurrent transactions" do
    amount = 100
    threads = []
    
    5.times do
      threads << Thread.new do
        @handler.create(
          sender: @sender,
          recipient: @recipient,
          amount: amount,
          currency: 'USD'
        )
      end
    end
    
    threads.each(&:join)
    
    @sender.reload
    assert_equal 500, @sender.balance
  end

  test "handles concurrent transfers correctly" do
    sender = create(:account, balance: 1000)
    recipient = create(:account, balance: 0)
    handler = TransactionHandler.new

    threads = 3.times.map do
      Thread.new do
        handler.create(
          sender: sender,
          recipient: recipient,
          amount: 300,
          currency: 'USD'
        )
      end
    end

    threads.each(&:join)

    sender.reload
    recipient.reload

    assert_equal 100, sender.balance
    assert_equal 900, recipient.balance
  end
end
