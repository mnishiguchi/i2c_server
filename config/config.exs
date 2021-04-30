import Config

config :i2c_server,
  transport_module: Circuits.I2C,
  registry_module: I2cServer.DeviceRegistry

import_config "#{Mix.env()}.exs"
