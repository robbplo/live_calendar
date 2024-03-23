defmodule LiveCalendar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveCalendarWeb.Telemetry,
      LiveCalendar.Repo,
      {DNSCluster, query: Application.get_env(:live_calendar, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveCalendar.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveCalendar.Finch},
      # Start a worker by calling: LiveCalendar.Worker.start_link(arg)
      # {LiveCalendar.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveCalendarWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveCalendar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveCalendarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
