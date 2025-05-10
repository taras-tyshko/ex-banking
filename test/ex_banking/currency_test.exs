defmodule ExBanking.CurrencyTest do
  use ExUnit.Case

  alias ExBanking.Currency

  describe "format/1" do
    test "formats integer to float with 2 decimal places" do
      assert Currency.format(100) == 100.0
      assert Currency.format(0) == 0.0
    end

    test "formats float to 2 decimal places" do
      assert Currency.format(100.123) == 100.12
      assert Currency.format(100.125) == 100.13
      assert Currency.format(0.0) == 0.0
    end
  end

  describe "validate/1" do
    test "returns :ok for positive numbers" do
      assert :ok = Currency.validate(100)
      assert :ok = Currency.validate(0.1)
    end

    test "returns error for zero" do
      assert {:error, :wrong_arguments} = Currency.validate(0)
    end

    test "returns error for negative numbers" do
      assert {:error, :wrong_arguments} = Currency.validate(-1)
      assert {:error, :wrong_arguments} = Currency.validate(-0.1)
    end

    test "returns error for non-numbers" do
      assert {:error, :wrong_arguments} = Currency.validate("string")
      assert {:error, :wrong_arguments} = Currency.validate(nil)
      assert {:error, :wrong_arguments} = Currency.validate([])
    end
  end

  describe "validate_currency/1" do
    test "returns :ok for non-empty strings" do
      assert :ok = Currency.validate_currency("USD")
      assert :ok = Currency.validate_currency("Euro")
    end

    test "returns error for empty string" do
      assert {:error, :wrong_arguments} = Currency.validate_currency("")
    end

    test "returns error for non-strings" do
      assert {:error, :wrong_arguments} = Currency.validate_currency(123)
      assert {:error, :wrong_arguments} = Currency.validate_currency(nil)
      assert {:error, :wrong_arguments} = Currency.validate_currency([])
    end
  end
end
