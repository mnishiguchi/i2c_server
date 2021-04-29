defmodule I2cServer.DeviceSupervisorTest do
  use ExUnit.Case
  alias I2cServer.DeviceSupervisor
  doctest I2cServer.DeviceSupervisor

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

  test "server_process" do
    pid1 = I2cServer.server_process("i2c-1", 0x77)
    pid2 = I2cServer.server_process("i2c-1", 0x76)
    pid3 = I2cServer.server_process("i2c-2", 0x38)
    assert is_pid(pid1)

    # Always the same pid for the same composite key
    assert I2cServer.server_process("i2c-1", 0x77) == pid1
    assert I2cServer.server_process("i2c-1", 0x77) == pid1

    # Different pid for each composite key
    refute pid2 == pid1
    refute pid3 == pid1
    refute pid3 == pid2
  end
end
