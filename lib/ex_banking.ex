defmodule ExBanking do
  @moduledoc """
  API for banking operations.

  This module provides functionality for managing user accounts,
  depositing and withdrawing money, and transferring funds between users.
  """
  alias ExBanking.User

  @doc """
  Creates a new user with a unique name.

  ## Parameters
    * `user` - User name, a non-empty string

  ## Returns
    * `:ok` - If the user was created successfully
    * `{:error, :wrong_arguments}` - If the user name is invalid
    * `{:error, :user_already_exists}` - If a user with this name already exists
  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) and user != "" do
    User.create(user)
  end

  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  Deposits money to the user's account in the given currency.

  ## Parameters
    * `user` - User name, a non-empty string
    * `amount` - Amount to deposit, a positive number
    * `currency` - Currency name, a non-empty string

  ## Returns
    * `{:ok, balance}` - If the deposit was successful, with the new balance
    * `{:error, reason}` - If the operation failed
  """
  @spec deposit(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, new_balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and user != "" and is_binary(currency) and currency != "" and
             is_number(amount) and amount > 0 do
    User.deposit(user, amount, currency)
  end

  def deposit(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Withdraws money from the user's account in the given currency.

  ## Parameters
    * `user` - User name, a non-empty string
    * `amount` - Amount to withdraw, a positive number
    * `currency` - Currency name, a non-empty string

  ## Returns
    * `{:ok, balance}` - If the withdrawal was successful, with the new balance
    * `{:error, reason}` - If the operation failed
  """
  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, new_balance :: number()}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency)
      when is_binary(user) and user != "" and is_binary(currency) and currency != "" and
             is_number(amount) and amount > 0 do
    User.withdraw(user, amount, currency)
  end

  def withdraw(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Gets the user's balance in the given currency.

  ## Parameters
    * `user` - User name, a non-empty string
    * `currency` - Currency name, a non-empty string

  ## Returns
    * `{:ok, balance}` - The current user balance
    * `{:error, reason}` - If the operation failed
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency)
      when is_binary(user) and user != "" and is_binary(currency) and currency != "" do
    User.get_balance(user, currency)
  end

  def get_balance(_, _), do: {:error, :wrong_arguments}

  @doc """
  Sends money from one user to another.

  ## Parameters
    * `from_user` - Sender's name, a non-empty string
    * `to_user` - Receiver's name, a non-empty string
    * `amount` - Amount to send, a positive number
    * `currency` - Currency name, a non-empty string

  ## Returns
    * `{:ok, from_balance, to_balance}` - If the transfer was successful
    * `{:error, reason}` - If the operation failed
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, from_balance :: number(), to_balance :: number()}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and from_user != "" and is_binary(to_user) and to_user != "" and
             from_user != to_user and is_binary(currency) and currency != "" and is_number(amount) and
             amount > 0 do
    User.send_money(from_user, to_user, amount, currency)
  end

  def send(_, _, _, _), do: {:error, :wrong_arguments}
end
