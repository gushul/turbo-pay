class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :cancel]

  def index
    @transactions = current_user.transactions.order(created_at: :desc)
  end

  def show
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = transaction_handler.create(
      sender: current_user.accounts.find(transaction_params[:sender_account_id]),
      recipient: Account.find(transaction_params[:recipient_account_id]),
      amount: transaction_params[:amount].to_d,
      currency: transaction_params[:currency],
      scheduled_for: transaction_params[:scheduled_for].presence
    )

    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.append("transactions", @transaction),
          turbo_stream.update("balance", current_user.balance_for_currency(@transaction.currency))
        ]
      }
      format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
    end


  rescue TransactionHandler::Error => e
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.update(
          "transaction_form", 
          partial: "form", 
          locals: { transaction: @transaction, error: e.message }
        )
      }
      format.html {
        flash.now[:alert] = e.message
        render :new
      }
    end
  end

  def cancel
    transaction_handler.cancel(@transaction)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to transactions_path, notice: 'Transaction was cancelled.' }
    end
  rescue TransactionHandler::Error => e
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.update(
          "transaction_#{@transaction.id}_status",
          "Failed to cancel: #{e.message}"
        )
      }
      format.html {
        redirect_to transactions_path, alert: e.message
      }
    end
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :sender_account_id,
      :recipient_account_id,
      :amount,
      :currency,
      :scheduled_for
    )
  end

  def transaction_handler
    @transaction_handler ||= TransactionHandler.new
  end
end
