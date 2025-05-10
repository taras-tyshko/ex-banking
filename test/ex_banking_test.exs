defmodule ExBankingTest do
  use ExUnit.Case
  import ExBanking.TestHelpers

  setup do
    clear_all_request_counters()
    :ok
  end

  describe "create_user/1" do
    test "successfully creates a user" do
      assert :ok = ExBanking.create_user("user1")
    end

    test "returns error when creating existing user" do
      create_user("user2")
      assert {:error, :user_already_exists} = ExBanking.create_user("user2")
    end

    test "returns error with invalid arguments" do
      assert {:error, :wrong_arguments} = ExBanking.create_user("")
      assert {:error, :wrong_arguments} = ExBanking.create_user(123)
    end

    test "user names are case sensitive" do
      create_user("User3")
      assert :ok = ExBanking.create_user("user3")
      assert {:error, :user_already_exists} = ExBanking.create_user("User3")
    end
  end

  describe "deposit/3" do
    test "successfully deposits money" do
      create_user("deposit_user")
      assert {:ok, 100.0} = ExBanking.deposit("deposit_user", 100, "USD")
    end

    test "returns error with invalid arguments" do
      assert {:error, :wrong_arguments} = ExBanking.deposit("", 100, "USD")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user", -10, "USD")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user", 10, "")
      assert {:error, :wrong_arguments} = ExBanking.deposit(nil, 100, "USD")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user", nil, "USD")
      assert {:error, :wrong_arguments} = ExBanking.deposit("user", 100, nil)
    end

    test "returns error if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("non_existing_user", 100, "USD")
    end

    test "returns error when request limit is reached" do
      create_user("limited_user")
      set_request_limit("limited_user", 10)

      assert {:error, :too_many_requests_to_user} = ExBanking.deposit("limited_user", 10, "USD")
    end
  end

  describe "withdraw/3" do
    test "successfully withdraws money" do
      create_user_with_balance("user4", 100, "USD")
      assert {:ok, 50.0} = ExBanking.withdraw("user4", 50, "USD")
    end

    test "returns error with insufficient funds" do
      create_user("user5")
      assert {:error, :not_enough_money} = ExBanking.withdraw("user5", 50, "USD")
    end

    test "returns error with invalid arguments" do
      assert {:error, :wrong_arguments} = ExBanking.withdraw("", 100, "USD")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user", -10, "USD")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user", 10, "")
      assert {:error, :wrong_arguments} = ExBanking.withdraw(nil, 100, "USD")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user", nil, "USD")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("user", 100, nil)
    end

    test "returns error if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("non_existing_user", 50, "USD")
    end

    test "returns error when request limit is reached" do
      create_user("limited_user2")
      set_request_limit("limited_user2", 10)

      assert {:error, :too_many_requests_to_user} = ExBanking.withdraw("limited_user2", 10, "USD")
    end
  end

  describe "get_balance/2" do
    test "successfully gets balance" do
      create_user_with_balance("user6", 100, "USD")
      assert {:ok, 100.0} = ExBanking.get_balance("user6", "USD")
    end

    test "returns 0 for account with no operations" do
      create_user("user7")
      assert {:ok, 0.0} = ExBanking.get_balance("user7", "USD")
    end

    test "returns error with invalid arguments" do
      assert {:error, :wrong_arguments} = ExBanking.get_balance("", "USD")
      assert {:error, :wrong_arguments} = ExBanking.get_balance("user", "")
      assert {:error, :wrong_arguments} = ExBanking.get_balance(nil, "USD")
      assert {:error, :wrong_arguments} = ExBanking.get_balance("user", nil)
    end

    test "returns error if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("non_existing_user", "USD")
    end

    test "returns error when request limit is reached" do
      create_user("limited_user3")
      set_request_limit("limited_user3", 10)

      assert {:error, :too_many_requests_to_user} = ExBanking.get_balance("limited_user3", "USD")
    end
  end

  describe "send/4" do
    test "successfully transfers money" do
      create_user_with_balance("from_user", 100, "USD")
      create_user("to_user")

      assert {:ok, 50.0, 50.0} = ExBanking.send("from_user", "to_user", 50, "USD")
      assert {:ok, 50.0} = ExBanking.get_balance("from_user", "USD")
      assert {:ok, 50.0} = ExBanking.get_balance("to_user", "USD")
    end

    test "returns error with insufficient funds" do
      create_user("from_user2")
      create_user("to_user2")

      assert {:error, :not_enough_money} = ExBanking.send("from_user2", "to_user2", 50, "USD")
    end

    test "returns error with invalid arguments" do
      assert {:error, :wrong_arguments} = ExBanking.send("", "to_user", 50, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", "", 50, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", "to_user", -10, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", "to_user", 50, "")
      assert {:error, :wrong_arguments} = ExBanking.send(nil, "to_user", 50, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", nil, 50, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", "to_user", nil, "USD")
      assert {:error, :wrong_arguments} = ExBanking.send("from_user", "to_user", 50, nil)
      assert {:error, :wrong_arguments} = ExBanking.send("same_user", "same_user", 50, "USD")
    end

    test "returns error if sender doesn't exist" do
      create_user("to_user3")

      assert {:error, :sender_does_not_exist} =
               ExBanking.send("non_existing_user", "to_user3", 50, "USD")
    end

    test "returns error if receiver doesn't exist" do
      create_user("from_user3")

      assert {:error, :receiver_does_not_exist} =
               ExBanking.send("from_user3", "non_existing_user", 50, "USD")
    end

    test "returns error when sender request limit is reached" do
      create_user("limited_sender")
      create_user("receiver")
      set_sender_request_limit("limited_sender", 10)

      assert {:error, :too_many_requests_to_sender} =
               ExBanking.send("limited_sender", "receiver", 10, "USD")
    end

    test "returns error when receiver request limit is reached" do
      create_user_with_balance("sender", 100, "USD")
      create_user("limited_receiver")
      set_receiver_request_limit("limited_receiver", 10)

      assert {:error, :too_many_requests_to_receiver} =
               ExBanking.send("sender", "limited_receiver", 10, "USD")
    end
  end

  describe "currency operations" do
    test "correctly formats decimal places" do
      create_user("currency_user")

      {:ok, _} = ExBanking.deposit("currency_user", 100.123, "USD")
      assert {:ok, 100.12} = ExBanking.get_balance("currency_user", "USD")

      {:ok, _} = ExBanking.deposit("currency_user", 50.125, "USD")
      assert {:ok, 150.25} = ExBanking.get_balance("currency_user", "USD")
    end

    test "handles multiple currencies separately" do
      create_user("multi_currency")

      {:ok, _} = ExBanking.deposit("multi_currency", 100, "USD")
      {:ok, _} = ExBanking.deposit("multi_currency", 200, "EUR")

      assert {:ok, 100.0} = ExBanking.get_balance("multi_currency", "USD")
      assert {:ok, 200.0} = ExBanking.get_balance("multi_currency", "EUR")
    end

    test "currency types are case sensitive" do
      create_user("currency_case_user")

      # Deposit money in both usd and USD currencies
      {:ok, _} = ExBanking.deposit("currency_case_user", 100, "USD")
      {:ok, _} = ExBanking.deposit("currency_case_user", 50, "usd")

      # They should be separate balances
      assert {:ok, 100.0} = ExBanking.get_balance("currency_case_user", "USD")
      assert {:ok, 50.0} = ExBanking.get_balance("currency_case_user", "usd")
    end

    test "automatically creates new currencies when needed" do
      create_user("new_currency_user")

      # New currency should be created automatically for the user
      assert {:ok, 75.5} = ExBanking.deposit("new_currency_user", 75.5, "NEW_CURRENCY")
      assert {:ok, 75.5} = ExBanking.get_balance("new_currency_user", "NEW_CURRENCY")

      # Another new currency
      assert {:ok, 33.33} = ExBanking.deposit("new_currency_user", 33.33, "ANOTHER_CURRENCY")
      assert {:ok, 33.33} = ExBanking.get_balance("new_currency_user", "ANOTHER_CURRENCY")

      # Original currency should still have zero balance
      assert {:ok, 0.0} = ExBanking.get_balance("new_currency_user", "USD")
    end
  end

  describe "performance isolation" do
    test "operations on user A do not affect user B" do
      # Create two users
      create_user("user_a")
      create_user("user_b")

      # Deposit money to their accounts
      {:ok, _} = ExBanking.deposit("user_a", 100, "USD")
      {:ok, _} = ExBanking.deposit("user_b", 200, "USD")

      # Set request limit for user A
      set_request_limit("user_a", 10)

      # Check that request to user A returns a limit error
      assert {:error, :too_many_requests_to_user} = ExBanking.get_balance("user_a", "USD")

      # But request to user B still works normally
      assert {:ok, 200.0} = ExBanking.get_balance("user_b", "USD")

      # Operations for user B continue to work
      assert {:ok, 300.0} = ExBanking.deposit("user_b", 100, "USD")
      assert {:ok, 250.0} = ExBanking.withdraw("user_b", 50, "USD")

      # And even after these operations, requests to user A are still limited
      assert {:error, :too_many_requests_to_user} = ExBanking.get_balance("user_a", "USD")
    end

    test "operations can be performed concurrently for different users" do
      # Create users
      create_user("concurrent_user_1")
      create_user("concurrent_user_2")

      # Deposit money to their accounts
      {:ok, _} = ExBanking.deposit("concurrent_user_1", 1000, "USD")
      {:ok, _} = ExBanking.deposit("concurrent_user_2", 1000, "USD")

      # Create tasks for concurrent operations
      task1 =
        Task.async(fn ->
          for _ <- 1..5 do
            ExBanking.withdraw("concurrent_user_1", 100, "USD")
          end
        end)

      task2 =
        Task.async(fn ->
          for _ <- 1..5 do
            ExBanking.deposit("concurrent_user_2", 100, "USD")
          end
        end)

      # Wait for both tasks to complete
      Task.await(task1)
      Task.await(task2)

      # Check results
      assert {:ok, 500.0} = ExBanking.get_balance("concurrent_user_1", "USD")
      assert {:ok, 1500.0} = ExBanking.get_balance("concurrent_user_2", "USD")
    end
  end
end
