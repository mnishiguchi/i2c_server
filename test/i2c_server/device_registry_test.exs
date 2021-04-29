defmodule I2cServer.DeviceRegistryTest do
  use ExUnit.Case
  alias I2cServer.DeviceRegistry
  doctest I2cServer.DeviceRegistry

  test "keys/1" do
    pid = I2cServer.server_process("i2c-1", 1)

    assert DeviceRegistry.keys(pid) == [{"i2c-1", 1}]
  end

  test "unregister/1" do
    _pid = I2cServer.server_process("i2c-1", 1)

    assert :ok = DeviceRegistry.unregister({"i2c-1", 1})
  end
end
