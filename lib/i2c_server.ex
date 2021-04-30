defmodule I2cServer do
  @moduledoc """
  I2C Server wraps [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/readme.html) [reference](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html#id67235) in a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html), creating a separate
  process for each [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) device. I2C device processes are
  identified with a composite key of bus name and bus address. By default, I2C device processes are
  stored in [`Registry`](https://hexdocs.pm/elixir/Registry.html), but you can alternatively use
  [`:global`](http://erlang.org/doc/man/global.html).
  """

  @type registry :: I2cServer.DeviceRegistry | :global | atom

  @doc """
  Returns the module atom of currently-used registry.
  """
  @spec registry() :: registry
  def registry() do
    Application.get_env(:i2c_server, :registry_module, I2cServer.DeviceRegistry)
  end

  @doc """
  Returns the PID for a specified bus name and bus address.
  """
  @spec server_process(binary, 0..127) :: pid
  def server_process(bus_name, bus_address) do
    I2cServer.DeviceSupervisor.server_process(bus_name, bus_address)
  end

  @doc """
  Initiates a read transaction to the I2C device.
  """
  @spec read(GenServer.server(), integer) :: any
  def read(server, read_count) when is_integer(read_count) do
    I2cServer.DeviceWorker.read(server, read_count)
  end

  @doc """
  Writes data to the I2C device.
  """
  @spec write(GenServer.server(), iodata) :: any
  def write(server, register_data) when is_binary(register_data) or is_list(register_data) do
    I2cServer.DeviceWorker.write(server, register_data)
  end

  @spec write(GenServer.server(), integer, binary | integer) :: any
  def write(server, register, data)
      when is_integer(register) and (is_binary(data) or is_integer(data)) do
    I2cServer.DeviceWorker.write(server, register, data)
  end

  @doc """
  Writes data to an I2C device and then immediately issue a read.
  """
  @spec write_read(GenServer.server(), binary | integer, integer) :: any
  def write_read(server, write_data, read_count)
      when is_binary(write_data) and is_integer(read_count) do
    I2cServer.DeviceWorker.write_read(server, write_data, read_count)
  end

  def write_read(server, register, read_count)
      when is_integer(register) and is_integer(read_count) do
    I2cServer.DeviceWorker.write_read(server, <<register>>, read_count)
  end
end
