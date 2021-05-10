defmodule I2cServer do
  @moduledoc """
  I2C Server wraps [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/readme.html)
  [reference](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html#id67235)
  in a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html), creating a separate process per
  [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) bus.
  """

  use GenServer

  @type bus_registry :: I2cServer.Busbus_registry | :global | atom

  @type bus_name :: binary

  @type bus_address :: 0..127

  @type init_arg :: [
          bus_name: bus_name,
          bus_address: bus_address
        ]

  @doc """
  Returns the module atom of currently-used bus registry.
  """
  @spec bus_registry() :: bus_registry
  def bus_registry() do
    Application.get_env(:i2c_server, :bus_registry_module, I2cServer.BusRegistry)
  end

  @spec start_link(init_arg) :: GenServer.on_start()
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @doc """
  Initiates a read transaction to the I2C device.
  """
  @spec read(GenServer.server(), integer) :: any
  def read(server, read_count) when is_integer(read_count) do
    GenServer.call(server, {:read, read_count})
  end

  @doc """
  Writes data to the I2C device.
  """
  @spec write(GenServer.server(), iodata) :: any
  def write(server, register_and_data)
      when is_binary(register_and_data) or is_list(register_and_data) do
    GenServer.call(server, {:write, register_and_data})
  end

  @spec write(GenServer.server(), integer, binary | integer) :: any
  def write(server, register, data)
      when is_integer(register) and (is_binary(data) or is_integer(data)) do
    GenServer.call(server, {:write, register, data})
  end

  @doc """
  Writes data to an I2C device and then immediately issue a read.
  """
  @spec write_read(GenServer.server(), binary | integer, integer) :: any
  def write_read(server, write_data, read_count)
      when is_binary(write_data) and is_integer(read_count) do
    GenServer.call(server, {:write_read, write_data, read_count})
  end

  def write_read(server, register, read_count)
      when is_integer(register) and is_integer(read_count) do
    GenServer.call(server, {:write_read, <<register>>, read_count})
  end

  @impl GenServer
  def init(args) when is_list(args) do
    state = %{
      bus_name: Keyword.fetch!(args, :bus_name),
      bus_address: Keyword.fetch!(args, :bus_address)
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call({:read, read_count}, _from, state) do
    %{bus_name: bus_name, bus_address: bus_address} = state
    pid = bus_server_process(bus_name)

    result = I2cServer.BusWorker.read(pid, bus_address, read_count)

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:write, register_and_data}, _from, state) do
    %{bus_name: bus_name, bus_address: bus_address} = state
    pid = bus_server_process(bus_name)

    result = I2cServer.BusWorker.write(pid, bus_address, register_and_data)

    {:reply, result, state}
  end

  def handle_call({:write, register, data}, _from, state) do
    %{bus_name: bus_name, bus_address: bus_address} = state
    pid = bus_server_process(bus_name)

    result = I2cServer.BusWorker.write(pid, bus_address, register, data)

    {:reply, result, state}
  end

  def handle_call({:write_read, register, read_count}, _from, state) do
    %{bus_name: bus_name, bus_address: bus_address} = state
    pid = bus_server_process(bus_name)

    result = I2cServer.BusWorker.write_read(pid, bus_address, register, read_count)

    {:reply, result, state}
  end

  defp bus_server_process(bus_name) do
    I2cServer.BusSupervisor.server_process(bus_name)
  end
end
