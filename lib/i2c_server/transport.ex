defmodule I2cServer.Transport do
  @moduledoc """
  I2cServer.Transport lets you communicate with hardware devices using the I2C protocol.
  """

  @type bus_name :: binary

  @type bus_address :: 0..127

  @callback open(bus_name) ::
              {:ok, reference} | {:error, any}

  @callback write(reference, bus_address, iodata) ::
              :ok | {:error, any}

  @callback read(reference, bus_address, pos_integer) ::
              {:ok, binary} | {:error, any}

  @callback write_read(reference, bus_address, iodata, pos_integer) ::
              {:ok, binary} | {:error, any}
end
