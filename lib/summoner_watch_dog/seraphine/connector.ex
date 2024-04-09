defmodule SummonerWatchDog.Seraphine.Connector do
  @moduledoc """
  Communications with Riot API via Seraphine lib
  """
  require Logger

  @region_routings %{
    "americas" => ~w(na1 br1 la1 la2),
    "asia" => ~w(jp1 kr),
    "europe" => ~w(eun1 euw1 tr1 ru),
    "sea" => ~w(oc1 ph2 sg2 th2 tw2 vn2)
  }

  @routing_regions %{
    "br1" => "americas",
    "eun1" => "europe",
    "euw1" => "europe",
    "jp1" => "asia",
    "kr" => "asia",
    "la1" => "americas",
    "la2" => "americas",
    "na1" => "americas",
    "oc1" => "sea",
    "ph2" => "sea",
    "ru" => "europe",
    "sg2" => "sea",
    "th2" => "sea",
    "tr1" => "europe",
    "tw2" => "sea",
    "vn2" => "sea"
  }

  @regions Map.keys(@routing_regions)
  @routings Map.keys(@region_routings)

  def region_routings, do: @region_routings
  def regions, do: @regions
  def routings, do: @routings

  @typedoc "na1 | br1 | la1 | la2 | jp1 | kr | eun1 | euw1 | tr1 | ru | oc1 | ph2 | sg2 | th2 | tw2 | vn2"
  @type region :: binary()

  @typedoc "americas | europe | asia | sea"
  @type routing :: binary()

  @type summoner_info :: %{
          required(:puuid) => puuid(),
          required(:summoner_name) => summoner_name()
        }

  @type puuid :: binary()
  @type summoner_name() :: binary()
  @type match_id() :: binary()

  @spec get_puuid_by_name(region(), binary()) ::
          {:ok, puuid()} | {:error, :get_puuid_failed}
  def get_puuid_by_name(region, name) do
    Logger.metadata(riot_summoner_name: name, riot_region: region)

    {:ok, %{puuid: puuid}, _} = Seraphine.SummonerV4.summoner_by_name(region, name)
    {:ok, puuid}
  rescue
    seraphine_error ->
      Logger.error("Failed to fetch summoner by name", seraphine_error: seraphine_error.message)
      {:error, :get_puuid_failed}
  end

  @spec list_matches_participants(puuid(), region(), non_neg_integer()) ::
          {:ok, [summoner_info()]}
          | {:error, :list_matches_failed}
          | {:error, :list_match_participants_failed}
  def list_matches_participants(puuid, region, matches_count) do
    routing = @routing_regions[region]

    with {:ok, match_ids} <- list_summoner_matches(region, puuid, matches_count),
         {:ok, participants} <- collect_matches_participants(routing, match_ids) do
      {:ok, Enum.uniq(participants)}
    end
  end

  @spec list_summoner_matches(region(), puuid(), non_neg_integer()) ::
          {:ok, [match_id()]} | {:error, :list_matches_failed}
  def list_summoner_matches(region, puuid, matches_count) do
    routing = @routing_regions[region]

    Logger.metadata(riot_puuid: puuid, riot_routing: routing)
    {:ok, match_ids, _headers} = Seraphine.MatchV5.matches_by_puuid(routing, puuid, matches_count)
    {:ok, match_ids}
  rescue
    seraphine_error ->
      Logger.error("Failed to fetch matches by puuid", seraphine_error: seraphine_error.message)
      {:error, :list_matches_failed}
  end

  @spec list_match_participants(routing(), match_id()) ::
          {:ok, [summoner_info()]} | {:error, :list_match_participants_failed}
  def list_match_participants(routing, match_id) do
    {:ok, %{info: %{participants: participants}}, _headers} =
      Seraphine.MatchV5.match_by_id(routing, match_id)

    Logger.info("Fetched participants summoner played with", riot_match_id: match_id)
    {:ok, Enum.map(participants, &summoner_info/1)}
  rescue
    seraphine_error ->
      Logger.error("Failed to fetch matches participants by puuid",
        seraphine_error: seraphine_error.message
      )

      {:error, :list_match_participants_failed}
  end

  #############################################################################
  ## Internal
  @spec collect_matches_participants(routing(), [match_id()]) ::
          {:ok, [summoner_info()]}
          | {:error, :list_match_participants_failed}

  defp collect_matches_participants(routing, match_ids) do
    match_ids
    |> Enum.reduce_while([], fn match_id, acc ->
      case list_match_participants(routing, match_id) do
        {:ok, summoners_info} -> {:cont, summoners_info ++ acc}
        error -> {:halt, error}
      end
    end)
    |> case do
      summoners_info when is_list(summoners_info) -> {:ok, summoners_info}
      {:error, :list_match_participants_failed} -> {:error, :list_match_participants_failed}
    end
  end

  @spec summoner_info(map()) :: summoner_info()
  defp summoner_info(%{puuid: puuid, summonerName: summoner_name}) do
    %{puuid: puuid, summoner_name: summoner_name}
  end
end
