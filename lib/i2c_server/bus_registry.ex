defmodule I2cServer.BusRegistry do
  @moduledoc false

  @spec child_spec(any) :: Supervisor.child_spec()
  def child_spec(_args) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  @doc """
  Starts a unique registry.
  """
  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @doc """
  Returns a via tuple for accessing a process that is held in this registry.

  ## Examples

      iex> BusRegistry.via("i2c-1", 0x77)
      {:via, Registry, {I2cServer.BusRegistry, {"i2c-1", 119}}}

  """
  @spec via(binary, integer) :: {:via, Registry, {I2cServer.BusRegistry, {binary, integer}}}
  def via(bus_name, bus_address) when is_binary(bus_name) and is_integer(bus_address) do
    {:via, Registry, {__MODULE__, {bus_name, bus_address}}}
  end

  @spec whereis_name(binary, integer) :: :undefined | pid
  def whereis_name(bus_name, bus_address) when is_binary(bus_name) and is_integer(bus_address) do
    Registry.whereis_name({__MODULE__, {bus_name, bus_address}})
  end
end
