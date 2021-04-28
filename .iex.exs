alias I2cServer.BusRegistry
alias I2cServer.BusWorker
alias I2cServer.I2cDevice

import Mox

Mox.set_mox_from_context([])
Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cDeviceStub)
