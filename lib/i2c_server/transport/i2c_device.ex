defmodule I2cServer.I2cDevice do
  @moduledoc false

  @behaviour I2cServer.Transport

  @doc """
  Open an I2C bus.
  """
  def open(bus_name) do
    apply(transport_module(), :open, [bus_name])
  end

  @doc """
  Write `data` to the I2C device at `bus_address`.
  """
  def write(reference, bus_address, data) do
    apply(transport_module(), :write, [reference, bus_address, data])
  end

  @doc """
  Initiate a read transaction to the I2C device at the specified `bus_address`.
  """
  def read(reference, bus_address, read_count) do
    apply(transport_module(), :read, [reference, bus_address, read_count])
  end

  @doc """
  Write `data` to an I2C device and then immediately issue a read.
  """
  def write_read(reference, bus_address, data, read_count) do
    apply(transport_module(), :write_read, [reference, bus_address, data, read_count])
  end

  defp transport_module() do
    # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
    Application.get_env(:i2c_server, :transport_module, Circuits.I2C)
  end
end
