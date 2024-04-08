defmodule SummonerWatchDog.Seraphine.Connector do
  @moduledoc """
  Communications with Riot API via Seraphine lib
  """
  require Logger
  @routings ~w(americas europe asia)

  @typedoc "br1 | eun1 | euw1 | jp1 | kr | la1 | la2 | na1 | oc1 | tr1 | ru"
  @type region :: binary()

  @typedoc "americas | europe | asia"
  @type routing :: binary()

  @type summoner_info :: %{
          required(:puuid) => puuid(),
          required(:summoner_name) => summoner_name()
        }

  @type puuid :: binary()
  @type summoner_name() :: binary()

  @spec get_summoner_puuid_by_name(region(), binary()) ::
          {:ok, puuid()} | {:error, :get_summoner_puuid_failed}
  def get_summoner_puuid_by_name(region, name) do
    Logger.metadata(riot_summoner_name: name, riot_region: region)

    {:ok, %{puuid: puuid}, _} = Seraphine.SummonerV4.summoner_by_name(region, name)
    {:ok, puuid}
  rescue
    error in Seraphine.Api.ApiHttpErrorCode ->
      Logger.error("Failed to fetch summoner by name", seraphine_error: error.message)
      {:error, :get_summoner_puuid_failed}
  end

  @spec list_matches_participants(puuid(), non_neg_integer()) ::
          {:ok, [puuid()]} | {:error, :list_match_participants_failed}
  def list_matches_participants(puuid, matches_count) do
    @routings
    |> Enum.reduce_while([], fn routing, participants ->
      case list_matches_participants_by_routing(routing, puuid, matches_count) do
        {:ok, routing_participants} -> {:cont, routing_participants ++ participants}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      participants when is_list(participants) -> {:ok, Enum.uniq(participants)}
      {:error, error} -> {:error, error}
    end
  end

  #############################################################################
  ## Internal

  @spec list_matches_participants_by_routing(routing(), puuid(), non_neg_integer()) ::
          {:ok, [summoner_info()]} | {:error, :list_match_participants_failed}
  defp list_matches_participants_by_routing(routing, puuid, matches_count) do
    Logger.metadata(riot_summoner_puuid: puuid, riot_routing: routing)
    {:ok, match_ids, _headers} = Seraphine.MatchV5.matches_by_puuid(routing, puuid, matches_count)

    matches_summoners =
      Enum.flat_map(match_ids, fn match_id ->
        {:ok, %{info: %{participants: participants}}, _headers} =
          Seraphine.MatchV5.match_by_id(routing, match_id)

        Logger.info("Fetched participants summoner played with", riot_match_id: match_id)

        Enum.map(participants, &summoner_info/1)
      end)

    {:ok, matches_summoners}
  rescue
    error in Seraphine.Api.ApiHttpErrorCode ->
      Logger.error("Failed to fetch matches participants by puuid", seraphine_error: error.message)

      {:error, :list_match_participants_failed}
  end

  @spec summoner_info(map()) :: summoner_info()
  defp summoner_info(%{puuid: puuid, summonerName: summoner_name}) do
    %{puuid: puuid, summoner_name: summoner_name}
  end
end
