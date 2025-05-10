defmodule ExBanking.UserServerTest do
  use ExUnit.Case

  alias ExBanking.UserServer

  describe "GenServer callbacks" do
    test "init/1 initializes with empty map" do
      assert {:ok, %{}} = UserServer.init([])
    end

    test "handle_call for deposit updates balance" do
      accounts = %{}
      result = UserServer.handle_call({:deposit, 100, "USD"}, {self(), :ref}, accounts)

      assert {:reply, {:ok, 100.0}, %{"USD" => 100.0}} = result
    end

    test "handle_call for withdraw with sufficient funds" do
      accounts = %{"USD" => 100.0}
      result = UserServer.handle_call({:withdraw, 50, "USD"}, {self(), :ref}, accounts)

      assert {:reply, {:ok, 50.0}, %{"USD" => 50.0}} = result
    end

    test "handle_call for withdraw with insufficient funds" do
      accounts = %{"USD" => 20.0}
      result = UserServer.handle_call({:withdraw, 50, "USD"}, {self(), :ref}, accounts)

      assert {:reply, {:error, :not_enough_money}, %{"USD" => 20.0}} = result
    end

    test "handle_call for get_balance returns formatted balance" do
      accounts = %{"USD" => 100.0}
      result = UserServer.handle_call({:get_balance, "USD"}, {self(), :ref}, accounts)

      assert {:reply, {:ok, 100.0}, %{"USD" => 100.0}} = result
    end

    test "handle_call for get_balance returns 0 for non-existent currency" do
      accounts = %{}
      result = UserServer.handle_call({:get_balance, "USD"}, {self(), :ref}, accounts)

      assert {:reply, {:ok, 0.0}, %{}} = result
    end
  end
end
