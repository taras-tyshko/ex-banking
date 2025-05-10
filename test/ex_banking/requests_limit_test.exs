defmodule ExBanking.RequestsLimitTest do
  use ExUnit.Case

  alias ExBanking.RequestsLimit

  setup do
    # Clear ETS table between tests
    :ets.delete_all_objects(:requests_counter)
    :ok
  end

  describe "check_user_limit/1" do
    test "returns :ok when under the limit" do
      assert :ok = RequestsLimit.check_user_limit("test_user")
    end

    test "returns error when limit is reached" do
      # Set counter to maximum
      :ets.insert(:requests_counter, {"test_user", 10})

      assert {:error, :too_many_requests_to_user} = RequestsLimit.check_user_limit("test_user")
    end
  end

  describe "check_sender_limit/1" do
    test "returns :ok when under the limit" do
      assert :ok = RequestsLimit.check_sender_limit("test_sender")
    end

    test "returns error when limit is reached" do
      # Set counter to maximum
      :ets.insert(:requests_counter, {"sender_test_sender", 10})

      assert {:error, :too_many_requests_to_sender} =
               RequestsLimit.check_sender_limit("test_sender")
    end
  end

  describe "check_receiver_limit/1" do
    test "returns :ok when under the limit" do
      assert :ok = RequestsLimit.check_receiver_limit("test_receiver")
    end

    test "returns error when limit is reached" do
      # Set counter to maximum
      :ets.insert(:requests_counter, {"receiver_test_receiver", 10})

      assert {:error, :too_many_requests_to_receiver} =
               RequestsLimit.check_receiver_limit("test_receiver")
    end
  end

  describe "decrement counters" do
    test "decrement_user_counter reduces the counter" do
      :ets.insert(:requests_counter, {"test_user", 5})

      RequestsLimit.decrement_user_counter("test_user")
      [{_, count}] = :ets.lookup(:requests_counter, "test_user")

      assert count == 4
    end

    test "decrement_sender_counter reduces the counter" do
      :ets.insert(:requests_counter, {"sender_test_user", 5})

      RequestsLimit.decrement_sender_counter("test_user")
      [{_, count}] = :ets.lookup(:requests_counter, "sender_test_user")

      assert count == 4
    end

    test "decrement_receiver_counter reduces the counter" do
      :ets.insert(:requests_counter, {"receiver_test_user", 5})

      RequestsLimit.decrement_receiver_counter("test_user")
      [{_, count}] = :ets.lookup(:requests_counter, "receiver_test_user")

      assert count == 4
    end
  end
end
