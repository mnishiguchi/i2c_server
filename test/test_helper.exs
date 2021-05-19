Application.put_env(:i2c_server, :transport_module, I2cServer.MockTransport)
Mox.defmock(I2cServer.MockTransport, for: I2cServer.Transport)

ExUnit.start()
