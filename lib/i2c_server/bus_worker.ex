defmodule I2cServer.BusWorker do
  @moduledoc false

  use GenServer, restart: :permanent

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
    case apply(bus_registry_module(), :whereis_name, [bus_name]) do
      :undefined -> nil
      pid -> pid
    end
  end

  @spec server_name(bus_name) :: server_name
  def server_name(bus_name) do
    case bus_registry_module() do
      :global -> {:global, bus_name}
      _default -> I2cServer.BusRegistry.via(bus_name)
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
      when (is_binary(write_data) or is_list(write_data)) and is_integer(read_count) do
    GenServer.call(server, {:write_read, bus_address, write_data, read_count})
  end

  def write_read(server, bus_address, register, read_count)
      when is_integer(register) and is_integer(read_count) do
    GenServer.call(server, {:write_read, bus_address, <<register>>, read_count})
  end

  @spec bulk(GenServer.server(), bus_address, [
          {:sleep, integer}
          | {atom, atom, list}
          | {:read, integer}
          | {:write, integer, iodata}
          | {:write, integer, integer, binary | integer}
          | {:write_read, binary | integer, integer}
          | function()
        ]) :: list
  def bulk(server, bus_address, bulk_operations) when is_list(bulk_operations) do
    GenServer.call(server, {:bulk, bus_address, bulk_operations})
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

  def handle_call({:bulk, bus_address, bulk_operations}, _from, state) do
    params = Map.merge(state, %{bus_address: bus_address})

    result =
      bulk_operations
      |> bulk_operations_to_funs
      |> Stream.map(fn f -> f.(params) end)
      |> Enum.to_list()

    {:reply, result, state}
  end

  defp bulk_operations_to_funs(bulk_operations) do
    Stream.map(bulk_operations, fn
      # fn _ -> "something" end
      anon_fun when is_function(anon_fun) ->
        fn params -> anon_fun.(params) end

      # {:sleep, 10}
      {:sleep, ms} when is_integer(ms) ->
        fn _params -> Process.sleep(ms) end

      # {Process, :sleep, [10]}
      {mod, fun, args} when is_atom(mod) and is_atom(fun) and is_list(args) ->
        fn _params -> apply(mod, fun, args) end

      # {:write, 0x8A, <<0xFF>>}
      fun_name_and_args when is_tuple(fun_name_and_args) ->
        [fun_name | args] = Tuple.to_list(fun_name_and_args)

        fn %{i2c_ref: i2c_ref, bus_address: bus_address} ->
          apply(I2cServer.I2cBus, fun_name, [i2c_ref, bus_address] ++ args)
        end

      _ ->
        raise ArgumentError, """
        A list entry must be tuple or anonymous function. Examples:

            fn _ -> "something" end
            {:sleep, 10}
            {Process, :sleep, [10]}
            {:read, 1}
            {:write, [0x8A, <<0xFF>>]}
            {:write_read, 0x8A, 1}

        """
    end)
  end

  defp bus_registry_module() do
    Application.get_env(:i2c_server, :bus_registry_module, I2cServer.BusRegistry)
  end
end
