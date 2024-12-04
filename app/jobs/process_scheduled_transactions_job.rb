class ProcessScheduledTransactionsJob < ApplicationJob
  queue_as :default

  def perform
    Transaction.ready_for_execution.find_each do |transaction|
      ProcessTransactionJob.perform_later(transaction.id)
    end
  end
end
