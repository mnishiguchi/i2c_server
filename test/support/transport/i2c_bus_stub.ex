defmodule I2cServer.I2cBusStub do
  @moduledoc false

  @behaviour I2cServer.Transport

  def open(_bus_name) do
    {:ok, Kernel.make_ref()}
  end

  def write(_reference, _bus_address, _data) do
    :ok
  end

  def read(_reference, _bus_address, _read_count) do
    {:ok, "stub"}
  end

  def write_read(_reference, _bus_address, _data, _read_count) do
    {:ok, "stub"}
  end
end
