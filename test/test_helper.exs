# Always warning as errors
if Version.match?(System.version(), "~> 1.10") do
  Code.put_compiler_option(:warnings_as_errors, true)
end

Application.put_env(:i2c_server, :transport_module, I2cServer.MockTransport)
Mox.defmock(I2cServer.MockTransport, for: I2cServer.Transport)

ExUnit.start()
