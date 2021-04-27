defmodule I2cServerTest do
  use ExUnit.Case
  doctest I2cServer

  test "greets the world" do
    assert I2cServer.hello() == :world
  end
end
