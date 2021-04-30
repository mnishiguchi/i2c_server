import Config

# Use the mocks defined in test/support/mocks.ex
# https://hexdocs.pm/mox/Mox.html
config :i2c_server,
  transport_module: I2cServer.MockTransport,
  registry_module: :global
