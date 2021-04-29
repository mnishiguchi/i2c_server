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
    Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cDeviceStub)
    :ok
  end

  test "server_process" do
    pid = I2cServer.server_process("i2c-1", 0x77)

    assert is_pid(pid)
  end

  test "read" do
    pid = I2cServer.server_process("i2c-1", 0x77)
    bytes_to_read = 23

    assert {:ok, _binary} = I2cServer.read(pid, bytes_to_read)
  end

  test "write" do
    pid = I2cServer.server_process("i2c-1", 0x77)
    register = 0x8A
    data = 0xFFF

    assert :ok = I2cServer.write(pid, register, data)
    assert :ok = I2cServer.write(pid, <<register, data>>)
  end

  test "write_read" do
    pid = I2cServer.server_process("i2c-1", 0x77)
    register = 0x8A
    bytes_to_read = 23

    assert {:ok, _binary} = I2cServer.write_read(pid, register, bytes_to_read)
    assert {:ok, _binary} = I2cServer.write_read(pid, <<register>>, bytes_to_read)
  end
end
