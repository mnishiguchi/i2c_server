# I2C Server

[![Hex.pm](https://img.shields.io/hexpm/v/i2c_server.svg)](https://hex.pm/packages/i2c_server)
[![API docs](https://img.shields.io/hexpm/v/i2c_server.svg?label=docs)](https://hexdocs.pm/i2c_server)
[![CI](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml)

I2C Server wraps [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/readme.html) [reference](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html#id67235) in a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html), creating a separate
process for each [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) device. I2C device processes are
identified with a composite key of bus name and bus address. By default, I2C device processes are
stored in [`Registry`](https://hexdocs.pm/elixir/Registry.html), but you can alternatively use
[`:global`](http://erlang.org/doc/man/global.html).

## Installation

Just add `i2c_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:i2c_server, "~> 0.1"}
  ]
end
```

## Usage

```elixir
# Get a PID for a device at the address 0x77 on the "i2c-1" bus
iex> device1 = I2cServer.server_process("i2c-1", 0x77)
#PID<0.233.0>

# A different device has a different PID
iex> device2 = I2cServer.server_process("i2c-1", 0x38)
#PID<0.239.0>

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

I2C device processes will be created under `I2cServer.I2cDeviceSupervisor` dynamically.

![](https://user-images.githubusercontent.com/7563926/116766985-62899000-a9fb-11eb-8a65-d06e199c2209.png)

## Configuration

You can change settings in your config file such as `config/config.exs` file. Here is the default
configuration.

```elixir
config :i2c_server,
  transport_module: Circuits.I2C,
  registry_module: I2cServer.DeviceRegistry
```

### Registry module

The default `:registry_module` is `I2cServer.DeviceRegistry` that is a thin wrapper of `Registry`.
You can alternatively use [`:global`](http://erlang.org/doc/man/global.html) for global registration.

```elixir
config :i2c_server,
  registry_module: :global
```

### Transport module

The default `:transport_module` is `Circuits.I2C`. You will most likely use the default, but you
may want to replace it with a mock for testing.

```elixir
config :i2c_server,
  transport_module: I2cServer.MockTransport
```
