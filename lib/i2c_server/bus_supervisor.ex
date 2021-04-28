defmodule I2cServer.BusSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec start_child(I2cServer.BusWorker.init_option()) :: DynamicSupervisor.on_start_child()
  def start_child(bus_worker_init_option) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {I2cServer.BusWorker, bus_worker_init_option}
    )
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
