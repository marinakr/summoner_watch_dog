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

  def enqueue_store(attrs) do
    attrs
    |> Map.put(:action, :store)
    |> __MODULE__.new()
    |> Oban.insert!()

    :ok
  end

  def enqueue_sync_matches(attrs) do
    attrs
    |> Map.put(:action, :sync_matches)
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
          "summoner_name" => summoner_name
        }
      }) do
    Summoners.store(region, puuid, summoner_name)
  end

  def perform(%Oban.Job{
        args: %{
          "action" => "store",
          "puuid" => puuid,
          "summoner_name" => summoner_name
        }
      }) do
    # https://developer.riotgames.com/apis#match-v5/GET_getMatch
    # participant region is not returned

    region = find_summoner_region(puuid, summoner_name)
    region && Summoners.store(region, puuid, summoner_name)
  end

  @latest_matches_count 10
  def perform(%{
        args: %{
          "action" => "sync_matches",
          "puuid" => puuid,
          "summoner_name" => name
        }
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

  def perform(%{args: %{"action" => "sync_matches"}}) do
    Summoner
    |> Repo.all()
    |> Enum.each(fn summoner ->
      enqueue_sync_matches(%{
        puuid: summoner.puuid,
        summoner_name: summoner.name
      })
    end)
  end

  def perform(%Oban.Job{id: id, args: _args}) do
    Logger.warn("SummonerWorker job #{id} ignored")
  end

  #############################################################################
  ## Internal

  @spec find_summoner_region(binary(), binary()) :: binary() | nil
  defp find_summoner_region(puuid, name) do
    Enum.reduce_while(Connector.regions(), nil, fn region, _ ->
      case Connector.get_summoner_name_by_puuid(region, puuid) do
        {:ok, ^name} -> {:halt, region}
        _ -> {:cont, nil}
      end
    end)
  end
end
