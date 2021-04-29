defmodule I2cServer.DeviceWorkerTest do
  use ExUnit.Case
  alias I2cServer.DeviceWorker
  doctest I2cServer.DeviceWorker

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
    assert DeviceWorker.via("i2c-1", 0x77) ==
             {:via, Registry, {I2cServer.DeviceRegistry, {"i2c-1", 119}}}
  end

  test "whereis" do
    {:ok, pid} = DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)

    assert DeviceWorker.whereis("i2c-1", 0x77) == pid
  end

  test "start_link" do
    assert {:ok, pid} = DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    assert %{bus_address: 119, bus_name: "i2c-1", i2c_ref: ref} = :sys.get_state(pid)
    assert is_reference(ref)

    assert {:ok, _pid} = DeviceWorker.start_link(bus_name: "i2c-2", bus_address: 0x76)
  end

  test "read" do
    {:ok, pid} = DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    bytes_to_read = 23

    assert {:ok, _binary} = DeviceWorker.read(pid, bytes_to_read)
  end

  test "write" do
    {:ok, pid} = DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A

    assert :ok = DeviceWorker.write(pid, register)
    assert :ok = DeviceWorker.write(pid, <<register>>)
  end

  test "write_read" do
    {:ok, pid} = DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    register = 0x8A
    bytes_to_read = 23

    assert {:ok, _binary} = DeviceWorker.write_read(pid, register, bytes_to_read)
    assert {:ok, _binary} = DeviceWorker.write_read(pid, <<register>>, bytes_to_read)
  end
end
