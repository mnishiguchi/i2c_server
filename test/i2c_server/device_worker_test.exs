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
    DeviceWorker.start_link(bus_name: "i2c-1", bus_address: 0x77)
    :ok
  end

  test "state" do
    pid = DeviceWorker.whereis("i2c-1", 0x77)

    assert %{bus_address: 119, bus_name: "i2c-1", i2c_ref: ref} = :sys.get_state(pid)
    assert is_reference(ref)
  end

  test "read" do
    pid = DeviceWorker.whereis("i2c-1", 0x77)
    read_count = 23

    assert {:ok, _binary} = DeviceWorker.read(pid, read_count)
  end

  test "write" do
    pid = DeviceWorker.whereis("i2c-1", 0x77)
    register = 0x8A
    data = 0xFFF

    assert :ok = DeviceWorker.write(pid, register, data)
    assert :ok = DeviceWorker.write(pid, register, <<data>>)
    assert :ok = DeviceWorker.write(pid, <<register, data>>)
    assert :ok = DeviceWorker.write(pid, [register, data])
    assert :ok = DeviceWorker.write(pid, [register, <<data>>])
  end

  test "write_read" do
    pid = DeviceWorker.whereis("i2c-1", 0x77)
    register = 0x8A
    read_count = 23

    assert {:ok, _binary} = DeviceWorker.write_read(pid, register, read_count)
    assert {:ok, _binary} = DeviceWorker.write_read(pid, <<register>>, read_count)
  end
end
