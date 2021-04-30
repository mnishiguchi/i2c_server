defmodule I2cServer.DeviceWorker do
  @moduledoc false

  use GenServer

  @type init_arg() :: [
          bus_name: binary,
          bus_address: 0..127
        ]

  @type server_name ::
          {:global, {binary, integer}}
          | {:via, Registry, {I2cServer.DeviceRegistry, {binary, integer}}}

  def child_spec(init_arg) do
    bus_name = Keyword.fetch!(init_arg, :bus_name)
    bus_address = Keyword.fetch!(init_arg, :bus_address)

    %{
      id: {__MODULE__, bus_name, bus_address},
      start: {__MODULE__, :start_link, [init_arg]}
    }
  end

  @spec whereis(binary, integer) :: nil | pid
  def whereis(bus_name, bus_address) when is_binary(bus_name) and is_integer(bus_address) do
    registry()
    |> apply(:whereis_name, [{bus_name, bus_address}])
    |> case do
      :undefined -> nil
      pid -> pid
    end
  end

  @spec server_name(binary, integer) :: server_name
  def server_name(bus_name, bus_address) do
    registry()
    |> case do
      :global -> {:global, {bus_name, bus_address}}
      _ -> I2cServer.DeviceRegistry.via(bus_name, bus_address)
    end
  end

  @spec start_link(init_arg) :: GenServer.on_start()
  def start_link(init_arg) do
    bus_name = Keyword.fetch!(init_arg, :bus_name)
    bus_address = Keyword.fetch!(init_arg, :bus_address)

    GenServer.start_link(__MODULE__, init_arg, name: server_name(bus_name, bus_address))
  end

  @spec read(GenServer.server(), integer) :: any
  def read(server, bytes_to_read) when is_integer(bytes_to_read) do
    GenServer.call(server, {:read, bytes_to_read})
  end

  @spec write(GenServer.server(), iodata) :: any
  def write(server, data) when is_binary(data) or is_list(data) do
    GenServer.call(server, {:write, data})
  end

  @spec write(GenServer.server(), integer, binary | integer) :: any
  def write(server, register, data)
      when is_integer(register) and (is_binary(data) or is_integer(data)) do
    GenServer.call(server, {:write, [register, data]})
  end

  @spec write_read(GenServer.server(), binary | integer, integer) :: any
  def write_read(server, write_data, bytes_to_read)
      when is_binary(write_data) and is_integer(bytes_to_read) do
    GenServer.call(server, {:write_read, write_data, bytes_to_read})
  end

  def write_read(server, register, bytes_to_read)
      when is_integer(register) and is_integer(bytes_to_read) do
    GenServer.call(server, {:write_read, <<register>>, bytes_to_read})
  end

  @impl GenServer
  def init(args) when is_list(args) do
    state = %{
      bus_name: Keyword.fetch!(args, :bus_name),
      bus_address: Keyword.fetch!(args, :bus_address),
      i2c_ref: nil
    }

    {:ok, state, {:continue, :init_i2c}}
  end

  @impl GenServer
  def handle_continue(:init_i2c, state) do
    {:ok, i2c_ref} = I2cServer.I2cDevice.open(state.bus_name)

    {:noreply, %{state | i2c_ref: i2c_ref}}
  end

  @impl GenServer
  def handle_call({:read, bytes_to_read}, _from, state) do
    result = I2cServer.I2cDevice.read(state.i2c_ref, state.bus_address, bytes_to_read)

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:write, data}, _from, state) do
    result = I2cServer.I2cDevice.write(state.i2c_ref, state.bus_address, data)

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:write_read, register, bytes_to_read}, _from, state) do
    result =
      I2cServer.I2cDevice.write_read(state.i2c_ref, state.bus_address, register, bytes_to_read)

    {:reply, result, state}
  end

  defp registry() do
    Application.get_env(:i2c_server, :registry_module, I2cServer.DeviceRegistry)
  end
end
