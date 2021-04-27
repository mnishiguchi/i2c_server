defmodule I2cServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: I2cServer.Worker.start_link(arg)
      # {I2cServer.Worker, arg}
      {I2cServer.BusRegistry, nil}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: I2cServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
