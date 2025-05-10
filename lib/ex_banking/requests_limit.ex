defmodule ExBanking.RequestsLimit do
  @moduledoc """
  Module for managing request rate limiting.
  """

  @max_requests 10

  @doc """
  Checks if the user can make a new request.
  Increments the request counter and returns :ok if under limit.
  Returns {:error, :too_many_requests_to_user} if limit is reached.
  """
  @spec check_user_limit(String.t()) :: :ok | {:error, :too_many_requests_to_user}
  def check_user_limit(user) do
    counter = :ets.update_counter(:requests_counter, user, {2, 1}, {user, 0})

    if counter <= @max_requests do
      :ok
    else
      :ets.update_counter(:requests_counter, user, {2, -1}, {user, 0})
      {:error, :too_many_requests_to_user}
    end
  end

  @doc """
  Checks if the sender can make a new request.
  Returns {:error, :too_many_requests_to_sender} if limit is reached.
  """
  @spec check_sender_limit(String.t()) :: :ok | {:error, :too_many_requests_to_sender}
  def check_sender_limit(user) do
    counter =
      :ets.update_counter(:requests_counter, "sender_#{user}", {2, 1}, {"sender_#{user}", 0})

    if counter <= @max_requests do
      :ok
    else
      :ets.update_counter(:requests_counter, "sender_#{user}", {2, -1}, {"sender_#{user}", 0})
      {:error, :too_many_requests_to_sender}
    end
  end

  @doc """
  Checks if the receiver can process a new request.
  Returns {:error, :too_many_requests_to_receiver} if limit is reached.
  """
  @spec check_receiver_limit(String.t()) :: :ok | {:error, :too_many_requests_to_receiver}
  def check_receiver_limit(user) do
    counter =
      :ets.update_counter(:requests_counter, "receiver_#{user}", {2, 1}, {"receiver_#{user}", 0})

    if counter <= @max_requests do
      :ok
    else
      :ets.update_counter(:requests_counter, "receiver_#{user}", {2, -1}, {"receiver_#{user}", 0})
      {:error, :too_many_requests_to_receiver}
    end
  end

  @doc """
  Decrements the request counter for a user.
  """
  @spec decrement_user_counter(String.t()) :: :ok
  def decrement_user_counter(user) do
    :ets.update_counter(:requests_counter, user, {2, -1}, {user, 0})
    :ok
  end

  @doc """
  Decrements the request counter for a sender.
  """
  @spec decrement_sender_counter(String.t()) :: :ok
  def decrement_sender_counter(user) do
    :ets.update_counter(:requests_counter, "sender_#{user}", {2, -1}, {"sender_#{user}", 0})
    :ok
  end

  @doc """
  Decrements the request counter for a receiver.
  """
  @spec decrement_receiver_counter(String.t()) :: :ok
  def decrement_receiver_counter(user) do
    :ets.update_counter(:requests_counter, "receiver_#{user}", {2, -1}, {"receiver_#{user}", 0})
    :ok
  end
end
