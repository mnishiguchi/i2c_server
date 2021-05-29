defmodule I2cServerTest do
  use ExUnit.Case
  doctest I2cServer

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Any process can consume mocks and stubs defined in your tests.
  setup :set_mox_from_context

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cBusStub)
    :ok
  end

  test "start_link" do
    {:ok, server} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
    assert %{bus_address: 119, bus_name: "i2c-1"} = :sys.get_state(server)
  end

  test "read" do
    {:ok, server} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
    read_count = 23

    assert {:ok, _binary} = I2cServer.read(server, read_count)
  end

  test "write" do
    {:ok, server} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A
    data = 0xFFF

    assert :ok = I2cServer.write(server, register, data)
    assert :ok = I2cServer.write(server, register, <<data>>)
    assert :ok = I2cServer.write(server, <<register, data>>)
    assert :ok = I2cServer.write(server, [register, data])
    assert :ok = I2cServer.write(server, [register, <<data>>])
  end

  test "write_read" do
    {:ok, server} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A
    read_count = 23

    assert {:ok, _binary} = I2cServer.write_read(server, register, read_count)
    assert {:ok, _binary} = I2cServer.write_read(server, <<register>>, read_count)
  end

  test "bulk" do
    {:ok, server} = I2cServer.start_link(bus_name: "i2c-1", bus_address: 0x77)

    I2cServer.bulk(server, [
      {:read, 1},
      {:write, [0x8A, <<0xFF>>]},
      {:sleep, 10},
      fn _ -> "something" end,
      {Process, :sleep, [10]},
      {:write_read, 0x8A, 1}
    ])
  end
end
