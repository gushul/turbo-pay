require "application_system_test_case"

class TransactionsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  
  setup do
    @sender = create(:user)
    @recipient = create(:user)
    
    @sender_account = create(:account, 
      user: @sender,
      balance: 1000,
      currency: 'USD'
    )
    
    @recipient_account = create(:account,
      user: @recipient,
      balance: 0,
      currency: 'USD'
    )
    
    sign_in @sender
  end

  test "creates an immediate transaction" do
    visit new_transaction_path
    
    select @sender_account.id, from: "transaction[sender_account_id]"
    select @recipient_account.id, from: "transaction[recipient_account_id]"
    fill_in "transaction[amount]", with: 100
    select "USD", from: "transaction[currency]"
    
    assert_difference("Transaction.count") do
      click_button "Create Transaction"
    end
    
    assert_text "Transaction was successfully created"
    
    @sender_account.reload
    @recipient_account.reload
    assert_equal 900, @sender_account.balance
    assert_equal 100, @recipient_account.balance
  end

  test "creates a scheduled transaction" do
    visit new_transaction_path
    
    select @sender_account.id, from: "transaction[sender_account_id]"
    select @recipient_account.id, from: "transaction[recipient_account_id]"
    fill_in "transaction[amount]", with: 100
    select "USD", from: "transaction[currency]"
    
    fill_in "transaction[scheduled_for]", with: 1.day.from_now
    
    assert_difference("Transaction.count") do
      click_button "Create Transaction"
    end
    
    assert_text "Transaction was successfully created"
    assert Transaction.last.pending?
    
    @sender_account.reload
    @recipient_account.reload
    assert_equal 1000, @sender_account.balance
    assert_equal 0, @recipient_account.balance
  end

  test "shows validation errors" do
    visit new_transaction_path
    
    click_button "Create Transaction"
    
    assert_text "Amount can't be blank"
    assert_text "Sender account must exist"
    assert_text "Recipient account must exist"
  end

  test "cannot create transaction with insufficient funds" do
    visit new_transaction_path
    
    select @sender_account.id, from: "transaction[sender_account_id]"
    select @recipient_account.id, from: "transaction[recipient_account_id]"
    fill_in "transaction[amount]", with: 2000  # Больше чем есть на балансе
    select "USD", from: "transaction[currency]"
    
    click_button "Create Transaction"
    
    assert_text "Insufficient funds"
    
    @sender_account.reload
    @recipient_account.reload
    assert_equal 1000, @sender_account.balance
    assert_equal 0, @recipient_account.balance
  end

  test "cancels scheduled transaction" do
    transaction = create(:transaction, 
      :scheduled,
      sender_account: @sender_account,
      recipient_account: @recipient_account,
      amount: 100,
      currency: 'USD',
      scheduled_for: 1.day.from_now
    )
    
    visit transaction_path(transaction)
    
    assert_changes -> { transaction.reload.status }, from: "pending", to: "cancelled" do
      click_button "Cancel Transaction"
    end
    
    assert_text "Transaction was cancelled"
  end
end
