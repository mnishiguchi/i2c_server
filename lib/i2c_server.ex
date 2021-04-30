defmodule I2cServer do
  @moduledoc """
  `I2cServer` creates a separate process for each I2C device. A server process
  is identified with a composite key of bus name and address.
  """

  def registry() do
    Application.get_env(:i2c_server, :registry_module, I2cServer.DeviceRegistry)
  end

  @spec server_process(binary, 0..127) :: pid
  def server_process(bus_name, bus_address) do
    I2cServer.DeviceSupervisor.server_process(bus_name, bus_address)
  end

  @spec read(GenServer.server(), integer) :: any
  def read(server, bytes_to_read) when is_integer(bytes_to_read) do
    I2cServer.DeviceWorker.read(server, bytes_to_read)
  end

  @spec write(GenServer.server(), iodata) :: any
  def write(server, data) when is_binary(data) or is_list(data) do
    I2cServer.DeviceWorker.write(server, data)
  end

  @spec write(GenServer.server(), integer, binary | integer) :: any
  def write(server, register, data)
      when is_integer(register) and (is_binary(data) or is_integer(data)) do
    I2cServer.DeviceWorker.write(server, register, data)
  end

  @spec write_read(GenServer.server(), binary | integer, integer) :: any
  def write_read(server, write_data, bytes_to_read)
      when is_binary(write_data) and is_integer(bytes_to_read) do
    I2cServer.DeviceWorker.write_read(server, write_data, bytes_to_read)
  end

  def write_read(server, register, bytes_to_read)
      when is_integer(register) and is_integer(bytes_to_read) do
    I2cServer.DeviceWorker.write_read(server, <<register>>, bytes_to_read)
  end
end
