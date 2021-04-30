alias I2cServer.DeviceRegistry
alias I2cServer.DeviceSupervisor
alias I2cServer.DeviceWorker
alias I2cServer.I2cDevice

import I2cServer
import Mox

Mox.set_mox_from_context([])
Mox.stub_with(I2cServer.MockTransport, I2cServer.I2cDeviceStub)
