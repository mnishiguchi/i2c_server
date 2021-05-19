defmodule I2cServer.BusWorker do
  @moduledoc false

  use GenServer

  @type bus_name :: binary

  @type bus_address :: 0..127

  @type init_arg() :: [
          bus_name: bus_name
        ]

  @type server_name ::
          {:global, bus_name}
          | {:via, Registry, {I2cServer.BusRegistry, bus_name}}

  def child_spec(init_arg) do
    bus_name = Keyword.fetch!(init_arg, :bus_name)

    %{
      id: {__MODULE__, bus_name},
      start: {__MODULE__, :start_link, [init_arg]}
    }
  end

  @spec whereis(binary) :: nil | pid
  def whereis(bus_name) when is_binary(bus_name) do
    registry()
    |> apply(:whereis_name, [bus_name])
    |> case do
      :undefined -> nil
      pid -> pid
    end
  end

  @spec server_name(bus_name) :: server_name
  def server_name(bus_name) do
    registry()
    |> case do
      :global -> {:global, bus_name}
      _ -> I2cServer.BusRegistry.via(bus_name)
    end
  end

  @spec start_link(init_arg) :: GenServer.on_start()
  def start_link(init_arg) do
    bus_name = Keyword.fetch!(init_arg, :bus_name)

    GenServer.start_link(__MODULE__, init_arg, name: server_name(bus_name))
  end

  @spec read(GenServer.server(), bus_address, integer) :: any
  def read(server, bus_address, read_count)
      when is_integer(read_count) do
    GenServer.call(server, {:read, bus_address, read_count})
  end

  @spec write(GenServer.server(), bus_address, iodata) :: any
  def write(server, bus_address, register_and_data)
      when is_binary(register_and_data) or is_list(register_and_data) do
    GenServer.call(server, {:write, bus_address, register_and_data})
  end

  @spec write(GenServer.server(), bus_address, integer, binary | integer) :: any
  def write(server, bus_address, register, data)
      when is_integer(register) and (is_binary(data) or is_integer(data)) do
    GenServer.call(server, {:write, bus_address, [register, data]})
  end

  @spec write_read(GenServer.server(), bus_address, binary | integer, integer) :: any
  def write_read(server, bus_address, write_data, read_count)
      when is_binary(write_data) and is_integer(read_count) do
    GenServer.call(server, {:write_read, bus_address, write_data, read_count})
  end

  def write_read(server, bus_address, register, read_count)
      when is_integer(register) and is_integer(read_count) do
    GenServer.call(server, {:write_read, bus_address, <<register>>, read_count})
  end

  @impl GenServer
  def init(args) when is_list(args) do
    bus_name = Keyword.fetch!(args, :bus_name)

    case I2cServer.I2cBus.open(bus_name) do
      {:ok, i2c_ref} -> {:ok, %{i2c_ref: i2c_ref, bus_name: bus_name}}
      _error -> {:stop, :bus_not_found}
    end
  end

  @impl GenServer
  def handle_call({:read, bus_address, read_count}, _from, state) do
    result = I2cServer.I2cBus.read(state.i2c_ref, bus_address, read_count)
    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:write, bus_address, data}, _from, state) do
    result = I2cServer.I2cBus.write(state.i2c_ref, bus_address, data)
    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:write_read, bus_address, register, read_count}, _from, state) do
    result = I2cServer.I2cBus.write_read(state.i2c_ref, bus_address, register, read_count)
    {:reply, result, state}
  end

  defp registry() do
    Application.get_env(:i2c_server, :bus_registry_module, I2cServer.BusRegistry)
  end
end
