import Config

config :i2c_server, transport_module: Circuits.I2C

import_config "#{Mix.env()}.exs"
