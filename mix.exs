defmodule I2cServer.MixProject do
  use Mix.Project

  @version "0.2.2"
  @source_url "https://github.com/mnishiguchi/i2c_server"

  def project do
    [
      app: :i2c_server,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: code(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      description: "Wrap an I2C device in a separate process per I2C bus",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {I2cServer.Application, []}
    ]
  end

  # Ensure test/support is compiled
  defp code(:dev), do: ["lib", "test/support"]
  defp code(:test), do: ["lib", "test/support"]
  defp code(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_i2c, "~> 0.3"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:mox, "~> 1.0.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package do
    %{
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE*"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    }
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      format: ["format", "credo"],
      test: ["test"]
    ]
  end
end
