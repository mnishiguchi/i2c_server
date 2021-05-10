defmodule I2cServer.I2cBus do
  @moduledoc false

  @behaviour I2cServer.Transport

  def open(bus_name) do
    apply(transport_module(), :open, [bus_name])
  end

  def write(reference, bus_address, data) do
    apply(transport_module(), :write, [reference, bus_address, data])
  end

  def read(reference, bus_address, read_count) do
    apply(transport_module(), :read, [reference, bus_address, read_count])
  end

  def write_read(reference, bus_address, data, read_count) do
    apply(transport_module(), :write_read, [reference, bus_address, data, read_count])
  end

  defp transport_module() do
    Application.get_env(:i2c_server, :transport_module, Circuits.I2C)
  end
end
