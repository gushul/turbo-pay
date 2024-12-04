require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    @sender_account = create(:account, user: @user, balance: 1000, currency: "USD")
    @recipient = create(:user)
    @recipient_account = create(:account, user: @recipient, balance: 0, currency: "USD")
    
    sign_in @user
  end

  test "should get index" do
    get transactions_path
    assert_response :success
  end

  test "should get new" do
    get new_transaction_path
    assert_response :success
  end

  test "should require authentication" do
    sign_out @user
    get transactions_path
    assert_redirected_to new_user_session_path
  end
end
