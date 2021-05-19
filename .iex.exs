alias I2cServer.BusRegistry
alias I2cServer.BusSupervisor
alias I2cServer.BusWorker
alias I2cServer.I2cDevice

import I2cServer
import Mox

# Set up a mock at runtime so we can play with a mock I2C in the IEx console
Application.put_env(:i2c_server, :transport_module, I2cServer.MockTransport)
Mox.defmock(I2cServer.MockTransport, for: I2cServer.Transport)
Mox.set_mox_from_context([])
Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cBusStub)
