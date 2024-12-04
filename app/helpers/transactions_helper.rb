module TransactionsHelper
  def currency_symbol(currency)
    case currency.to_s.upcase
    when 'USD' then '$'
    when 'EUR' then '€'
    else currency.to_s
    end
  end

  def transaction_status_class(transaction)
    case transaction.status.to_sym
    when :completed
      'bg-green-100 text-green-800'
    when :pending
      'bg-yellow-100 text-yellow-800'
    when :failed
      'bg-red-100 text-red-800'
    when :cancelled
      'bg-gray-100 text-gray-800'
    end
  end
end
