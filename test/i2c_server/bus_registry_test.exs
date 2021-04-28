defmodule I2cServer.BusRegistryTest do
  use ExUnit.Case
  alias I2cServer.BusRegistry
  doctest I2cServer.BusRegistry

  test "keys/1" do
    pid = I2cServer.server_process("i2c-1", 1)

    assert BusRegistry.keys(pid) == [{"i2c-1", 1}]
  end

  test "unregister/1" do
    pid = I2cServer.server_process("i2c-1", 1)

    assert :ok = BusRegistry.unregister({"i2c-1", 1})
  end
end
