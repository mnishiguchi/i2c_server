defmodule I2cServer do
  @moduledoc """
  `I2cServer` creates a separate process for each I2C device. A server process
  is identified with a composite key of bus name and address.
  """

  @spec server_process(binary, 0..127) :: pid
  def server_process(bus_name, bus_address) do
    I2cServer.BusSupervisor.server_process(bus_name, bus_address)
  end

  @spec read(GenServer.server(), integer) :: any
  def read(server, bytes_to_read) when is_integer(bytes_to_read) do
    I2cServer.BusWorker.read(server, bytes_to_read)
  end

  @spec write(GenServer.server(), binary | integer) :: any
  def write(server, data) when is_binary(data) do
    I2cServer.BusWorker.write(server, data)
  end

  def write(server, register) when is_integer(register) do
    I2cServer.BusWorker.write(server, <<register>>)
  end

  @spec write_read(GenServer.server(), binary | integer, integer) :: any
  def write_read(server, write_data, bytes_to_read)
      when is_binary(write_data) and is_integer(bytes_to_read) do
    I2cServer.BusWorker.write_read(server, write_data, bytes_to_read)
  end

  def write_read(server, register, bytes_to_read)
      when is_integer(register) and is_integer(bytes_to_read) do
    I2cServer.BusWorker.write_read(server, <<register>>, bytes_to_read)
  end
end
