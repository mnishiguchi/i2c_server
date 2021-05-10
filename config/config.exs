import Config

config :i2c_server,
  transport_module: Circuits.I2C,
  bus_registry_module: I2cServer.BusRegistry

import_config "#{Mix.env()}.exs"
