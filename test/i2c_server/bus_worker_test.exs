defmodule I2cServer.BusWorkerTest do
  use ExUnit.Case
  alias I2cServer.BusWorker
  doctest I2cServer.BusWorker

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Any process can consume mocks and stubs defined in your tests.
  setup :set_mox_from_context

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cBusStub)
    BusWorker.start_link(bus_name: "i2c-1")
    :ok
  end

  test "state" do
    pid = BusWorker.whereis("i2c-1")

    assert %{bus_name: "i2c-1", i2c_ref: ref} = :sys.get_state(pid)
    assert is_reference(ref)
  end

  test "read" do
    pid = BusWorker.whereis("i2c-1")
    bus_address = 0x77
    read_count = 23

    assert {:ok, _binary} = BusWorker.read(pid, bus_address, read_count)
  end

  test "write" do
    pid = BusWorker.whereis("i2c-1")
    bus_address = 0x77
    register = 0x8A
    data = 0xFFF

    assert :ok = BusWorker.write(pid, bus_address, register, data)
    assert :ok = BusWorker.write(pid, bus_address, register, <<data>>)
    assert :ok = BusWorker.write(pid, bus_address, <<register, data>>)
    assert :ok = BusWorker.write(pid, bus_address, [register, data])
    assert :ok = BusWorker.write(pid, bus_address, [register, <<data>>])
  end

  test "write_read" do
    pid = BusWorker.whereis("i2c-1")
    bus_address = 0x77
    register = 0x8A
    read_count = 23

    assert {:ok, _binary} = BusWorker.write_read(pid, bus_address, register, read_count)
    assert {:ok, _binary} = BusWorker.write_read(pid, bus_address, <<register>>, read_count)
  end
end
