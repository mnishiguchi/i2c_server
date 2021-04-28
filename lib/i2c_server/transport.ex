defmodule I2cServer.Transport do
  @moduledoc false

  @type bus_name :: binary
  @type bus_address :: 0..127

  @callback open(bus_name) :: {:ok, reference} | {:error, any}
  @callback write(reference, bus_address, binary) :: :ok | {:error, any}
  @callback read(reference, bus_address, integer) :: {:ok, binary} | {:error, any}
  @callback write_read(reference, bus_address, binary, integer) :: {:ok, binary} | {:error, any}
end

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
  def read(reference, bus_address, bytes_to_read) do
    apply(transport_module(), :read, [reference, bus_address, bytes_to_read])
  end

  @doc """
  Write `data` to an I2C device and then immediately issue a read.
  """
  def write_read(reference, bus_address, data, bytes_to_read) do
    apply(transport_module(), :write_read, [reference, bus_address, data, bytes_to_read])
  end

  defp transport_module() do
    # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
    Application.get_env(:i2c_server, :transport_module, Circuits.I2C)
  end
end

defmodule I2cServer.I2cDeviceStub do
  @moduledoc false

  @behaviour I2cServer.Transport

  def open(_bus_name), do: {:ok, Kernel.make_ref()}
  def write(_reference, _bus_address, _data), do: :ok
  def read(_reference, _bus_address, _bytes_to_read), do: {:ok, "stub"}
  def write_read(_reference, _bus_address, _data, _bytes_to_read), do: {:ok, "stub"}
end
