defmodule ExBanking.User do
  @moduledoc """
  Module for managing user accounts and operations.
  """
  require Logger
  alias ExBanking.RequestsLimit
  alias ExBanking.UserServer

  @request_timeout 5000

  # Client API

  @doc """
  Creates a new user.
  """
  @spec create(String.t()) :: :ok | {:error, :user_already_exists}
  def create(user) do
    case Registry.lookup(ExBanking.Registry, user) do
      [] ->
        case DynamicSupervisor.start_child(ExBanking.UserSupervisor, {UserServer, user}) do
          {:ok, _pid} -> :ok
          {:error, {:already_started, _}} -> {:error, :user_already_exists}
          {:error, _} -> {:error, :user_already_exists}
        end

      _ ->
        {:error, :user_already_exists}
    end
  end

  @doc """
  Deposits money to the user's account.
  """
  @spec deposit(String.t(), number(), String.t()) ::
          {:ok, number()} | {:error, :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- check_user_exists(user),
         :ok <- RequestsLimit.check_user_limit(user) do
      try do
        GenServer.call(UserServer.via_tuple(user), {:deposit, amount, currency}, @request_timeout)
      after
        RequestsLimit.decrement_user_counter(user)
      end
    end
  end

  @doc """
  Withdraws money from the user's account.
  """
  @spec withdraw(String.t(), number(), String.t()) ::
          {:ok, number()}
          | {:error, :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with :ok <- check_user_exists(user),
         :ok <- RequestsLimit.check_user_limit(user) do
      try do
        GenServer.call(
          UserServer.via_tuple(user),
          {:withdraw, amount, currency},
          @request_timeout
        )
      after
        RequestsLimit.decrement_user_counter(user)
      end
    end
  end

  @doc """
  Gets the user's balance for a specific currency.
  """
  @spec get_balance(String.t(), String.t()) ::
          {:ok, number()} | {:error, :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with :ok <- check_user_exists(user),
         :ok <- RequestsLimit.check_user_limit(user) do
      try do
        GenServer.call(UserServer.via_tuple(user), {:get_balance, currency}, @request_timeout)
      after
        RequestsLimit.decrement_user_counter(user)
      end
    end
  end

  @doc """
  Transfers money between users.
  """
  @spec send_money(String.t(), String.t(), number(), String.t()) ::
          {:ok, number(), number()}
          | {:error,
             :sender_does_not_exist
             | :receiver_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send_money(from_user, to_user, amount, currency) do
    with :ok <- check_sender_exists(from_user),
         :ok <- check_receiver_exists(to_user),
         :ok <- RequestsLimit.check_sender_limit(from_user),
         :ok <- RequestsLimit.check_receiver_limit(to_user) do
      try do
        GenServer.call(
          UserServer.via_tuple(from_user),
          {:send, to_user, amount, currency},
          @request_timeout
        )
      after
        RequestsLimit.decrement_sender_counter(from_user)
        RequestsLimit.decrement_receiver_counter(to_user)
      end
    end
  end

  # Private functions

  defp check_user_exists(user) do
    case Registry.lookup(ExBanking.Registry, user) do
      [] -> {:error, :user_does_not_exist}
      _ -> :ok
    end
  end

  defp check_sender_exists(user) do
    case Registry.lookup(ExBanking.Registry, user) do
      [] -> {:error, :sender_does_not_exist}
      _ -> :ok
    end
  end

  defp check_receiver_exists(user) do
    case Registry.lookup(ExBanking.Registry, user) do
      [] -> {:error, :receiver_does_not_exist}
      _ -> :ok
    end
  end
end
