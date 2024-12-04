class TransactionNotificationJob < ApplicationJob
  queue_as :default

  def perform(transaction_id, event)
    transaction = Transaction.find(transaction_id)
    
    case event
    when :completed
      notify_completion(transaction)
    when :failed
      notify_failure(transaction)
    end
  end

  private

  def notify_completion(transaction)
    Rails.logger.info "Transaction #{transaction.id} completed successfully"
    
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{transaction.sender_account.user_id}_transactions",
      target: "transaction_#{transaction.id}",
      partial: "transactions/transaction",
      locals: { transaction: transaction }
    )
    
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{transaction.sender_account.user_id}_balance",
      target: "balance_#{transaction.currency}",
      partial: "transactions/balance",
      locals: { account: transaction.sender_account }
    )
  end

  def notify_failure(transaction)
    Rails.logger.error "Transaction #{transaction.id} failed"
    
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{transaction.sender_account.user_id}_transactions",
      target: "transaction_#{transaction.id}",
      partial: "transactions/transaction",
      locals: { transaction: transaction }
    )
  end
end
