defmodule MetamaskLogin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MetamaskLogin.Repo,
      # Start the Telemetry supervisor
      MetamaskLoginWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MetamaskLogin.PubSub},
      # Start the Endpoint (http/https)
      MetamaskLoginWeb.Endpoint,
      # Start a worker by calling: MetamaskLogin.Worker.start_link(arg)
      # {MetamaskLogin.Worker, arg}
      {Cachex, name: :login}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MetamaskLogin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MetamaskLoginWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
