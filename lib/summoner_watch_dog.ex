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
  @type summoner_name() :: binary()

  @type summoner_info :: %{
          required(:puuid) => puuid(),
          required(:summoner_name) => summoner_name()
        }

  @doc """
  Returns puuids summoner played last matches with (5 by default or configured number of matches)

  Returns `["Summoner Name 1", "Summoner name 2", "Sunnoner name 3"]`.

  ## Examples

      iex> SummonerWatchDog.list_summoners_played_with("br1", "DuchaGG")
      ["0Mannel", "JVAS14", "allan pvp insano", "DuchaGG", "SPANK01", "bgod má fase",
        "GordaoDoGolzin", "Loco de Breja", "CrocodiloCabelud", "SenhorDaCachaça",
        "Lciang", "Opantero", "Missrael", "Titã Mizeravão", "Hamletizinho",
        "JussiCleido66", "Luizhmpontes", "l2Defendi", "semlee", "Angelico",
        "Christian5320", "The Shepherd", "bruno9191", "ZPr9o", "Chapecoense123",
        "Dancrazy", "Na Keria", "isonOx", "TUTUTIRULIPA", "Biel gala doce",
        "SrFISICOturista", "Alemao do Forro", "xêro de fimose", "BepplerFanBoy",
        "Alumínio", "im not your ally", "Cupcat", "vitoxgameprays", "AvarezaA",
        "amilanese onion", "TeMpL4rI0", "FanaticoLoko", "NANAMI CHAN", "Toma sombra",
        "Bocal Quadrado", "SKT Xandy Trynda"]
  """
  @spec list_summoners_played_with(region(), summoner_name()) ::
          [summoner_name()]
          | {:error, :get_summoner_puuid_failed}
          | {:error, :list_match_participants_failed}
  def list_summoners_played_with(region, name) do
    matches_count = config()[:matches_count] || @default_matches_count

    with {:ok, puuid} <- get_summoner_puuid_by_name(region, name),
         {:ok, summoners} <- list_matches_participants(puuid, matches_count) do
      Enum.map(summoners, & &1.summoner_name)
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
          {:ok, [summoner_info()]} | {:error, :list_match_participants_failed}
  defp list_matches_participants_by_routing(routing, puuid, matches_count) do
    Logger.metadata(riot_summoner_puuid: puuid, riot_routing: routing)
    {:ok, match_ids, _headers} = Seraphine.MatchV5.matches_by_puuid(routing, puuid, matches_count)

    # mb consider to use MapSet instead of list

    matches_summoners =
      match_ids
      |> Enum.flat_map(fn match_id ->
        Logger.metadata(riot_match_id: match_id)

        {:ok, %{info: %{participants: participants}}, _headers} =
          Seraphine.MatchV5.match_by_id(routing, match_id)

        Logger.info("Fetched participants summoner played with")

        # https://developer.riotgames.com/apis#match-v5/GET_getMatch
        # participant region is not returned, how can we know participant region?
        Enum.map(participants, &%{puuid: &1.puuid, summoner_name: &1.summonerName})
      end)
      |> Enum.uniq()

    {:ok, matches_summoners}
  rescue
    error in Seraphine.Api.ApiHttpErrorCode ->
      Logger.error("Failed to fetch matches participants by puuid", seraphine_error: error.message)

      {:error, :list_match_participants_failed}
  end

  @spec list_matches_participants(puuid(), non_neg_integer()) ::
          {:ok, [puuid()]} | {:error, :list_match_participants_failed}
  defp list_matches_participants(puuid, matches_count) do
    Enum.reduce_while(@routings, {:ok, []}, fn routing, {:ok, participants} ->
      case list_matches_participants_by_routing(routing, puuid, matches_count) do
        {:ok, routing_participants} -> {:cont, {:ok, routing_participants ++ participants}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  @spec config() :: Keyword.t()
  defp config do
    Application.get_env(@app, __MODULE__)
  end
end
