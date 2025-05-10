defmodule ExBanking.TestHelpers do
  @moduledoc """
  Helper functions for testing the banking system
  """

  @doc """
  Creates a user with the specified balance in a given currency
  """
  def create_user_with_balance(user, amount, currency) do
    :ok = ExBanking.create_user(user)
    {:ok, _} = ExBanking.deposit(user, amount, currency)
  end

  @doc """
  Creates a new user
  """
  def create_user(user) do
    :ok = ExBanking.create_user(user)
  end

  @doc """
  Sets the request limit for a user
  """
  def set_request_limit(user, limit) do
    :ets.insert(:requests_counter, {user, limit})
  end

  @doc """
  Clears all request counters
  """
  def clear_all_request_counters do
    :ets.delete_all_objects(:requests_counter)
  end

  @doc """
  Sets the request limit for a sender
  """
  def set_sender_request_limit(user, limit) do
    :ets.insert(:requests_counter, {"sender_#{user}", limit})
  end

  @doc """
  Sets the request limit for a receiver
  """
  def set_receiver_request_limit(user, limit) do
    :ets.insert(:requests_counter, {"receiver_#{user}", limit})
  end
end
