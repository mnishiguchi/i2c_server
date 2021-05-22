# I2C Server

[![Hex.pm](https://img.shields.io/hexpm/v/i2c_server.svg)](https://hex.pm/packages/i2c_server)
[![API docs](https://img.shields.io/hexpm/v/i2c_server.svg?label=docs)](https://hexdocs.pm/i2c_server)
[![CI](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml)

I2C Server wraps [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/readme.html) [reference](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html#id67235) in a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html), creating a separate
process per [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) bus. I2C bus processes are
identified with a bus name (e.g., `"i2c-1"`).

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
# Get a PID for the device at the address 0x77 on the "i2c-1" bus
iex> {:ok, device} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
#PID<0.233.0>

# Write 0xff to the register 0x8A
iex> I2cServer.write(device, [0x8A, <<0xff>>])
:ok

# Read 3 bytes
iex> I2cServer.read(device, 3)
:ok

# Read 3 bytes from the register 0xE1
iex> I2cServer.write_read(device, 0xE1, 3)
{:ok, <<0, 0, 0>>}

# Do multiple operations in series blocking the server process
iex> I2cServer.bulk(device, [
...>   {:write, [0xBA]},
...>   fn(_device, _address) -> Process.sleep(10) end,
...>   {:write, [0xAC, <<0x33, 0x00>>]}
...> ])
[:ok, :ok, :ok]
```

I2C bus processes will be created under `I2cServer.I2cBusSupervisor` dynamically.

![](https://user-images.githubusercontent.com/7563926/117657605-c2083e00-b167-11eb-8f76-3595b4fa5785.png)

## Configuration

You can change settings in your config file such as `config/config.exs` file.

### Registry module

By default, I2C bus processes are
stored in [`Registry`](https://hexdocs.pm/elixir/Registry.html), but you can alternatively use
[`:global`](http://erlang.org/doc/man/global.html).

```elixir
config :i2c_server,
  bus_registry_module: :global
```
