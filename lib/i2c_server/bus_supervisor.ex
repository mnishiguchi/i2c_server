defmodule I2cServer.BusSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec start_child(I2cServer.BusWorker.init_arg()) :: DynamicSupervisor.on_start_child()
  def start_child(init_arg) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {I2cServer.BusWorker, init_arg}
    )
  end

  @spec server_process(binary) :: pid
  def server_process(bus_name) do
    existing_process(bus_name) || new_process(bus_name)
  end

  defp existing_process(bus_name) do
    I2cServer.BusWorker.whereis(bus_name)
  end

  defp new_process(bus_name) do
    case start_child(bus_name: bus_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      error -> error
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
