# ExBanking

A simple banking OTP application in Elixir.

## API Reference

The application provides the following functions:

- `create_user/1` - Creates a new user
- `deposit/3` - Deposits money to a user's account
- `withdraw/3` - Withdraws money from a user's account
- `get_balance/2` - Gets a user's balance
- `send/4` - Transfers money between users

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_banking` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_banking, "~> 0.1.0"}
  ]
end
```

## Features

- User creation with zero initial balance
- Support for multiple currencies
- Money precision to 2 decimal places
- Request rate limiting (max 10 concurrent operations per user)
- No external storage dependencies (memory only)

## Examples

```elixir
# Create a user
ExBanking.create_user("john")

# Deposit money
ExBanking.deposit("John", 100, "USD")

# Check balance
ExBanking.get_balance("john", "USD")

# Withdraw money
ExBanking.withdraw("john", 20, "USD")

# Send money to another user
ExBanking.send("john", "Mary", 30, "USD")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_banking>.

