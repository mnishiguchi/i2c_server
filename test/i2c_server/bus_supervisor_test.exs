defmodule I2cServer.BusSupervisorTest do
  use ExUnit.Case
  alias I2cServer.BusSupervisor
  doctest I2cServer.BusSupervisor

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

  test "server_process" do
    pid1 = BusSupervisor.server_process("i2c-1")
    pid2 = BusSupervisor.server_process("i2c-2")
    assert is_pid(pid1)

    # Always the same pid for the same composite key
    assert BusSupervisor.server_process("i2c-1") == pid1

    # Different pid for each composite key
    refute pid2 == pid1
  end
end
