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
    Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cDeviceStub)
    :ok
  end

  test "via" do
    assert BusWorker.via("i2c-1", 0x77) ==
             {:via, Registry, {I2cServer.BusRegistry, {"i2c-1", 119}}}
  end

  test "whereis" do
    {:ok, pid} = BusWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)

    assert BusWorker.whereis("i2c-1", 0x77) == pid
  end

  test "start_link" do
    assert {:ok, pid} = BusWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    assert %{bus_address: 119, bus_name: "i2c-1", i2c_ref: ref} = :sys.get_state(pid)
    assert is_reference(ref)

    assert {:ok, _pid} = BusWorker.start_link(bus_name: "i2c-2", bus_address: 0x76)
  end

  test "read" do
    {:ok, pid} = BusWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    bytes_to_read = 23

    assert {:ok, _binary} = BusWorker.read(pid, bytes_to_read)
  end

  test "write" do
    {:ok, pid} = BusWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A

    assert :ok = BusWorker.write(pid, register)
    assert :ok = BusWorker.write(pid, <<register>>)
  end

  test "write_read" do
    {:ok, pid} = BusWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A
    bytes_to_read = 23

    assert {:ok, _binary} = BusWorker.write_read(pid, register, bytes_to_read)
    assert {:ok, _binary} = BusWorker.write_read(pid, <<register>>, bytes_to_read)
  end
end
