class ProcessTransactionJob < ApplicationJob
  queue_as :default
  
  retry_on TransactionHandler::Error, wait: 1.minute, attempts: 3, queue: :default
  
  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    TransactionHandler.new.process(transaction)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Transaction #{transaction_id} not found: #{e.message}"
  end
end
