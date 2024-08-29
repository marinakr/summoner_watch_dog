defmodule SummonerWatchDog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SummonerWatchDogWeb.Telemetry,
      SummonerWatchDog.Repo,
      {DNSCluster,
       query: Application.get_env(:summoner_watch_dog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SummonerWatchDog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SummonerWatchDog.Finch},
      # Start a worker by calling: SummonerWatchDog.Worker.start_link(arg)
      # {SummonerWatchDog.Worker, arg},
      # Start to serve requests, typically the last entry
      SummonerWatchDogWeb.Endpoint,
      {Oban, Application.fetch_env!(:summoner_watch_dog, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SummonerWatchDog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SummonerWatchDogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
