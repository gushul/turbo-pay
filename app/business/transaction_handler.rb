class TransactionHandler
  class Error < StandardError; end
  class InsufficientFundsError < Error; end
  class InvalidTransactionError < Error; end
  class AccountError < Error; end

  def create(sender:, recipient:, amount:, currency:, scheduled_for: nil)
    validate_accounts!(sender, recipient)
    validate_amount!(amount)
    validate_balance!(sender, amount) 

    ApplicationRecord.transaction do
      transaction = Transaction.create!(
        sender_account: sender,
        recipient_account: recipient,
        amount: amount,
        currency: currency,
        transaction_type: scheduled_for ? :scheduled : :immediate,
        scheduled_for: scheduled_for,
        status: :pending
      )

      process(transaction) if transaction.immediate?

      transaction
    end
  end

  def process(transaction)
    return if transaction.completed? || transaction.cancelled?
    
    ApplicationRecord.transaction do
      sender = transaction.sender_account.lock!("FOR UPDATE")
      recipient = transaction.recipient_account.lock!("FOR UPDATE")

      validate_balance!(sender, transaction.amount)
      
      sender.update!(balance: sender.balance - transaction.amount)
      recipient.update!(balance: recipient.balance + transaction.amount)
      
      transaction.update!(
        status: :completed,
        executed_at: Time.current
      )
      
      notify_status_change(transaction, :completed)
      log_transaction(transaction, :completed)
    end
  rescue Error => e
    handle_failure(transaction, e.message)
    raise e
  end

  def cancel(transaction)
    raise InvalidTransactionError, "Can't cancel this transaction" unless can_cancel?(transaction)

    ApplicationRecord.transaction do
      transaction.update!(status: :cancelled)
      notify_status_change(transaction, :cancelled)
      log_transaction(transaction, :cancelled)
    end
  end

  def schedule_pending
    Transaction.ready_for_execution.find_each do |transaction|
      process(transaction)
    rescue Error => e
      Rails.logger.error("Failed to process scheduled transaction #{transaction.id}: #{e.message}")
      next
    end
  end

  def retry_failed(transaction)
    raise InvalidTransactionError, "Only failed transactions can be retried" unless transaction.failed?
    
    transaction.update!(status: :pending)
    process(transaction)
  end

  private

  def validate_accounts!(sender, recipient)
    raise AccountError, "Invalid accounts" unless sender && recipient
    raise AccountError, "Same account transfer" if sender == recipient
    raise AccountError, "Currency mismatch" unless sender.currency == recipient.currency
  end

  def validate_amount!(amount)
    raise InvalidTransactionError, "Amount must be positive" unless amount.positive?
  end

  def validate_balance!(account, amount)
    raise InsufficientFundsError, "Insufficient funds" if account.balance < amount
  end

  def can_cancel?(transaction)
    transaction.scheduled? && 
    transaction.pending? && 
    transaction.scheduled_for > Time.current
  end

  
  def handle_failure(transaction, reason)
    transaction.update!(status: :failed)
    notify_status_change(transaction, :failed)
    log_transaction(transaction, :failed, reason: reason)
  end

  def notify_status_change(transaction, status)
    TransactionNotificationJob.perform_later(transaction.id, status)
  end

  def log_transaction(transaction, action, details = {})
    TransactionLog.create!(
      source: transaction,
      action: action,
      details: details
    )
  end
end

