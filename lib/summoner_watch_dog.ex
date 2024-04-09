defmodule SummonerWatchDog do
  @moduledoc """
  API for some RIOT summoners info
  """

  @default_matches_count 5

  alias SummonerWatchDog.Oban.SummonerWorker
  alias SummonerWatchDog.Seraphine.Connector

  @region_routings Connector.region_routings()
  @regions Connector.regions()
  @routings Connector.routings()

  @doc """
  Returns puuids summoner played last matches with (5 by default or configured number of matches)

  Returns `["Summoner Name 1", "Summoner name 2", "Sunnoner name 3"]`.

  ## Examples

      iex> SummonerWatchDog.list_summoners_played_with("br1", "DuchaGG")
      OR  
      iex> SummonerWatchDog.list_summoners_played_with("americas", "DuchaGG")
      
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
  @spec list_summoners_played_with(
          Connector.region() | Connector.routing(),
          Connector.summoner_name()
        ) ::
          [Connector.summoner_name()]
          | {:error, :get_puuid_failed}
          | {:error, :list_matches_failed}
          | {:error, :list_match_participants_failed}
          | {:error, :invalid_region}
          | {:error, :not_found}
  def list_summoners_played_with(region, summoner_name) when region in @regions do
    matches_count = config()[:matches_count] || @default_matches_count

    with {:ok, puuid} <- Connector.get_puuid_by_name(region, URI.encode(summoner_name)),
         {:ok, summoners} <- Connector.list_matches_participants(puuid, region, matches_count) do
      summoners = Enum.filter(summoners, &(&1.puuid != puuid))

      SummonerWorker.enqueue_store(summoner_name, region, puuid)

      # https://developer.riotgames.com/apis#match-v5/GET_getMatch
      # region is not returned, assume summoners play in same region
      Enum.each(summoners, &SummonerWorker.enqueue_store(&1.summoner_name, region, &1.puuid))

      Enum.map(summoners, & &1.summoner_name)
    end
  end

  def list_summoners_played_with(routing, summoner_name) when routing in @routings do
    # Not sure if this required or not, api works with regions (br1, oc1, etc)
    # but in docs routings called regions
    # So it is possible to find summoner by "americas", "Ducha GG"
    Enum.reduce_while(@region_routings[routing], {:error, :not_found}, fn region, err ->
      case list_summoners_played_with(region, summoner_name) do
        {:error, _} -> {:cont, err}
        names when is_list(names) -> {:halt, names}
      end
    end)
  end

  def list_summoners_played_with(_, _) do
    {:error, :invalid_region}
  end

  def region?(region) when region in @regions, do: true
  def region?(_), do: false

  def routing?(routing) when routing in @routings, do: true
  def routing?(_), do: false

  #############################################################################
  ## Internal
  def config, do: Application.get_env(:summoner_watch_dog, __MODULE__)
end
