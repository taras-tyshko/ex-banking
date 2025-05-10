defmodule ExBanking.UserServer do
  @moduledoc """
  Server part for managing user state through GenServer.
  """
  use GenServer
  require Logger
  alias ExBanking.Currency

  @request_timeout 5000

  # Server functions

  @doc """
  Starts a new GenServer process for the user.
  """
  def start_link(user) do
    GenServer.start_link(__MODULE__, %{}, name: via_tuple(user))
  end

  @doc """
  Returns the identifier for registering the process in Registry.
  """
  def via_tuple(user) do
    {:via, Registry, {ExBanking.Registry, user}}
  end

  # GenServer callbacks

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:deposit, amount, currency}, _from, accounts) do
    new_balance = Currency.format(Map.get(accounts, currency, 0) + amount)
    new_accounts = Map.put(accounts, currency, new_balance)
    {:reply, {:ok, new_balance}, new_accounts}
  end

  @impl true
  def handle_call({:withdraw, amount, currency}, _from, accounts) do
    current_balance = Map.get(accounts, currency, 0)

    if current_balance >= amount do
      new_balance = Currency.format(current_balance - amount)
      new_accounts = Map.put(accounts, currency, new_balance)
      {:reply, {:ok, new_balance}, new_accounts}
    else
      {:reply, {:error, :not_enough_money}, accounts}
    end
  end

  @impl true
  def handle_call({:get_balance, currency}, _from, accounts) do
    balance = Currency.format(Map.get(accounts, currency, 0))
    {:reply, {:ok, balance}, accounts}
  end

  @impl true
  def handle_call({:send, to_user, amount, currency}, _from, accounts) do
    current_balance = Map.get(accounts, currency, 0)

    if current_balance >= amount do
      case GenServer.call(via_tuple(to_user), {:deposit, amount, currency}, @request_timeout) do
        {:ok, to_balance} ->
          new_balance = Currency.format(current_balance - amount)
          new_accounts = Map.put(accounts, currency, new_balance)
          {:reply, {:ok, new_balance, to_balance}, new_accounts}

        error ->
          {:reply, error, accounts}
      end
    else
      {:reply, {:error, :not_enough_money}, accounts}
    end
  end
end
