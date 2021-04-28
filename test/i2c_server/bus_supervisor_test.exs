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
    Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cDeviceStub)
    :ok
  end

  test "start_child" do
    assert {:ok, _pid} = BusSupervisor.start_child(bus_name: "i2c-1", bus_address: 0x77)

    assert {:error, {:already_started, _pid}} =
             BusSupervisor.start_child(bus_name: "i2c-1", bus_address: 0x77)

    assert {:ok, _pid} = BusSupervisor.start_child(bus_name: "i2c-2", bus_address: 0x38)
  end
end
