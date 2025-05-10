defmodule ExBanking.Currency do
  @moduledoc """
  Module for handling currency operations and formatting.
  """

  @doc """
  Formats a number to have exactly 2 decimal places.
  """
  @spec format(number()) :: float()
  def format(amount) when is_number(amount) do
    Float.round(amount * 1.0, 2)
  end

  @doc """
  Validates that an amount is a positive number.
  """
  @spec validate(term()) :: :ok | {:error, :wrong_arguments}
  def validate(amount) when is_number(amount) and amount > 0, do: :ok
  def validate(_), do: {:error, :wrong_arguments}

  @doc """
  Validates that a currency is a non-empty string.
  """
  @spec validate_currency(term()) :: :ok | {:error, :wrong_arguments}
  def validate_currency(currency) when is_binary(currency) and currency != "", do: :ok
  def validate_currency(_), do: {:error, :wrong_arguments}
end
