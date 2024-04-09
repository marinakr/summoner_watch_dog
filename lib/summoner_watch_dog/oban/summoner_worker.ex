defmodule SummonerWatchDog.Oban.SummonerWorker do
  @moduledoc """
  async create summoner in DB, sync summoner matches with riot 
  """
  use Oban.Worker, max_attempts: 1

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Seraphine.Connector
  alias SummonerWatchDog.SummonerMatches
  alias SummonerWatchDog.Summoners
  alias SummonerWatchDog.Summoners.Summoner

  require Logger

  def enqueue_store(name, region, puuid) do
    %{name: name, region: region, puuid: puuid}
    |> Map.put(:action, :store)
    |> __MODULE__.new()
    |> Oban.insert!()

    :ok
  end

  def enqueue_sync_matches(puuid, name) do
    %{action: :sync_matches, puuid: puuid, name: name}
    |> __MODULE__.new()
    |> Oban.insert!()

    :ok
  end

  # We don't know how fast Riot API is going to work
  @impl Oban.Worker
  def timeout(%_{attempt: attempt}), do: attempt * :timer.seconds(30)

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "action" => "store",
          "region" => region,
          "puuid" => puuid,
          "name" => name
        }
      }) do
    Summoners.store(region, puuid, name)
  end

  @latest_matches_count 10
  def perform(%Oban.Job{
        args: %{"action" => "sync_matches", "puuid" => puuid, "name" => name}
      }) do
    # For PROD task, not `take home`, pagination and `gameEnd` parameted should be used
    with {:ok, summoner_matches} <- Connector.list_summoner_matches(puuid, @latest_matches_count) do
      Enum.each(summoner_matches, fn match_id ->
        unless SummonerMatches.get_by(puuid, match_id) do
          Logger.warning("Summoner #{name} completed match #{match_id}")
          SummonerMatches.store(puuid, match_id)
        end
      end)
    end
  end

  def perform(%Oban.Job{args: %{"action" => "sync_matches"}}) do
    Summoner
    |> Repo.all()
    |> Enum.each(&enqueue_sync_matches(&1.puuid, &1.name))
  end

  def perform(%Oban.Job{id: id, args: _args}) do
    Logger.warn("SummonerWorker job #{id} ignored")
  end
end
