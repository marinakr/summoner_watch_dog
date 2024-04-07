defmodule SummonerWatchDog do
  @moduledoc """
  API for some RIOT summoners info
  """
  require Logger

  @app :summoner_watch_dog
  @default_matches_count 5
  @routings ~w(americas europe asia)

  @typedoc "br1 | eun1 | euw1 | jp1 | kr | la1 | la2 | na1 | oc1 | tr1 | ru"
  @type region :: binary()

  @typedoc "americas | europe | asia"
  @type routing :: binary()

  @type puuid :: binary()

  @spec list_summoners_played_with(region(), binary()) ::
          [puuid()]
          | {:error, :get_summoner_puuid_failed}
          | {:error, :list_match_participants_failed}
  def list_summoners_played_with(region, name) do
    matches_count = config()[:matches_count] || @default_matches_count

    with {:ok, puuid} <- get_summoner_puuid_by_name(region, name),
         {:ok, puuids} <- list_matches_participants(puuid, matches_count) do
      # mb consider to use MapSet instead of list
      Enum.uniq(puuids)
    end
  end

  #############################################################################
  ## Internal

  # Seraphine lib functions raise errors on http error codes
  # Instead of exceptions, it's better to handle errors and know on what state it failed

  @spec get_summoner_puuid_by_name(region(), binary()) ::
          {:ok, puuid()} | {:error, :get_summoner_puuid_failed}
  defp get_summoner_puuid_by_name(region, name) do
    Logger.metadata(riot_summoner_name: name, riot_region: region)

    {:ok, %{puuid: puuid}, _} = Seraphine.SummonerV4.summoner_by_name(region, name)
    {:ok, puuid}
  rescue
    error in Seraphine.Api.ApiHttpErrorCode ->
      Logger.error("Failed to fetch summoner by name", seraphine_error: error.message)
      {:error, :get_summoner_puuid_failed}
  end

  @spec list_matches_participants_by_routing(routing(), puuid(), non_neg_integer()) ::
          {:ok, [puuid()]} | {:error, :list_match_participants_failed}
  defp list_matches_participants_by_routing(routing, puuid, matches_count) do
    Logger.metadata(riot_summoner_puuid: puuid, riot_routing: routing)
    {:ok, match_ids, _headers} = Seraphine.MatchV5.matches_by_puuid(routing, puuid, matches_count)

    matches_puuids =
      Enum.flat_map(match_ids, fn match_id ->
        Logger.metadata(riot_match_id: match_id)

        {:ok, %{metadata: %{participants: puuids}}, _headers} =
          Seraphine.MatchV5.match_by_id(routing, match_id)

        Logger.info("Fetched participants summoner played with")
        puuids
      end)

    {:ok, matches_puuids}
  rescue
    error in Seraphine.Api.ApiHttpErrorCode ->
      Logger.error("Failed to fetch matches participants by puuid", seraphine_error: error.message)

      {:error, :list_match_participants_failed}
  end

  @spec list_matches_participants(puuid(), non_neg_integer()) ::
          {:ok, [puuid()]} | {:error, :list_match_participants_failed}
  defp list_matches_participants(puuid, matches_count) do
    Enum.reduce_while(@routings, {:ok, []}, fn routing, {:ok, puuids} ->
      case list_matches_participants_by_routing(routing, puuid, matches_count) do
        {:ok, routing_puuids} -> {:cont, {:ok, puuids ++ routing_puuids}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  @spec config() :: Keyword.t()
  defp config do
    Application.get_env(@app, __MODULE__)
  end
end
