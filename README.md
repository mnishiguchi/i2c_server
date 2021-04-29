# I2C Server

[![CI](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/i2c_server/actions/workflows/ci.yml)

`I2cServer` is a thin wrapper of the `Circuits.I2C` library and creates a separate process for
communicating with each [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) device. A I2C device process
is stored in `Registry` and identified with a composite key of bus name and bus address.

## Installation

Just add `i2c_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:i2c_server, "~> 0.1"}
  ]
end
```

## Examples

```elixir
# Get a PID for a device at address 0x77 on "i2c-1" bus
iex> device1 = I2cServer.server_process("i2c-1", 0x77)
#PID<0.233.0>

# A different device has a different PID
iex> device2 = I2cServer.server_process("i2c-1", 0x38)
#PID<0.239.0>

# Write 0xff to register 0x8A
iex> I2cServer.write(device1, 0x8A, 0xff)
:ok

# Read 3 bytes from register 0xE1
iex> I2cServer.write_read(device1, 0xE1, 3)
{:ok, <<0, 0, 0>>}
```
