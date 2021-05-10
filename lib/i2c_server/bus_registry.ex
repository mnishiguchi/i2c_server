defmodule I2cServer.BusRegistry do
  @moduledoc false

  @type key :: binary

  @spec child_spec(any) :: Supervisor.child_spec()
  def child_spec(_args) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @doc """
  Returns a via tuple for accessing a process that is held in this registry.

  ## Examples

      iex> BusRegistry.via("i2c-1")
      {:via, Registry, {I2cServer.BusRegistry, "i2c-1"}}

  """
  @spec via(binary) :: {:via, Registry, {I2cServer.BusRegistry, binary}}
  def via(bus_name) when is_binary(bus_name) do
    {:via, Registry, {__MODULE__, bus_name}}
  end

  @spec whereis_name(key) :: :undefined | pid
  def whereis_name(bus_name) when is_binary(bus_name) do
    Registry.whereis_name({__MODULE__, bus_name})
  end

  @spec keys(pid) :: [key]
  def keys(pid) do
    Registry.keys(__MODULE__, pid)
  end
end
