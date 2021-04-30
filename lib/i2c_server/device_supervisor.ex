defmodule I2cServer.DeviceSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec start_child(I2cServer.DeviceWorker.init_arg()) :: DynamicSupervisor.on_start_child()
  def start_child(init_arg) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {I2cServer.DeviceWorker, init_arg}
    )
  end

  @spec server_process(binary, 0..127) :: pid
  def server_process(bus_name, bus_address) do
    existing_process(bus_name, bus_address) || new_process(bus_name, bus_address)
  end

  defp existing_process(bus_name, bus_address) do
    I2cServer.DeviceWorker.whereis(bus_name, bus_address)
  end

  defp new_process(bus_name, bus_address) do
    case start_child(bus_name: bus_name, bus_address: bus_address) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def which_children do
    # ID is always `:undefined` but it is normal behavior for Dynamic Supervisor.
    Supervisor.which_children(__MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
