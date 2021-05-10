# I2C Server

[![Hex.pm](https://img.shields.io/hexpm/v/i2c_server.svg)](https://hex.pm/packages/i2c_server)
[![API docs](https://img.shields.io/hexpm/v/i2c_server.svg?label=docs)](https://hexdocs.pm/i2c_server)
[![CI](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml)

I2C Server wraps [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/readme.html) [reference](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html#id67235) in a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html), creating a separate
process per [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) bus. I2C bus processes are
identified with a bus name (e.g., `"i2c-1"`). By default, I2C bus processes are
stored in [`Registry`](https://hexdocs.pm/elixir/Registry.html), but you can alternatively use
[`:global`](http://erlang.org/doc/man/global.html).

## Installation

Just add `i2c_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:i2c_server, "~> 0.2"}
  ]
end
```

## Usage

```elixir
# Get a PID for the "i2c-1" bus
iex> {:ok, device1} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
#PID<0.233.0>

# Write 0xff to the register 0x8A
iex> I2cServer.write(device1, 0x8A, 0xff)
iex> I2cServer.write(device1, 0x8A, <<0xff>>)
iex> I2cServer.write(device1, <<0x8A, 0xff>>)
iex> I2cServer.write(device1, [0x8A, 0xff])
iex> I2cServer.write(device1, [0x8A, <<0xff>>])
:ok

# Read 3 bytes from the register 0xE1
iex> I2cServer.write_read(device1, 0xE1, 3)
iex> I2cServer.write_read(device1, <<0xE1>>, 3)
{:ok, <<0, 0, 0>>}
```

I2C bus processes will be created under `I2cServer.I2cBusSupervisor` dynamically.

![](https://user-images.githubusercontent.com/7563926/117657605-c2083e00-b167-11eb-8f76-3595b4fa5785.png)

## Configuration

You can change settings in your config file such as `config/config.exs` file. Here is the default
configuration.

```elixir
config :i2c_server,
  transport_module: Circuits.I2C,
  bus_registry_module: I2cServer.BusRegistry
```

### Registry module

The default `:bus_registry_module` is `I2cServer.BusRegistry` that is a thin wrapper of `Registry`.
You can alternatively use [`:global`](http://erlang.org/doc/man/global.html) for global registration.

```elixir
config :i2c_server,
  bus_registry_module: :global
```

### Transport module

The default `:transport_module` is `Circuits.I2C`. You will most likely use the default, but you
may want to replace it with a mock for testing.

```elixir
config :i2c_server,
  transport_module: MyApp.MockTransport
```
