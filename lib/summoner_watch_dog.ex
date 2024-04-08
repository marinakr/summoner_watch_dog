defmodule SummonerWatchDog do
  @moduledoc """
  API for some RIOT summoners info
  """

  @app :summoner_watch_dog
  @default_matches_count 5

  alias SummonerWatchDog.Seraphine.Connector

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
  @spec list_summoners_played_with(Connector.region(), Connector.summoner_name()) ::
          [Connector.summoner_name()]
          | {:error, :get_summoner_puuid_failed}
          | {:error, :list_match_participants_failed}
  def list_summoners_played_with(region, summoner_name) do
    matches_count = config()[:matches_count] || @default_matches_count

    with {:ok, puuid} <- Connector.get_summoner_puuid_by_name(region, summoner_name),
         {:ok, summoners} <- Connector.list_matches_participants(puuid, matches_count) do
      monitor_summoners(summoners)
      Enum.map(summoners, & &1.summoner_name) -- [summoner_name]
    end
  end

  #############################################################################
  ## Internal

  # Seraphine lib functions raise errors on http error codes
  # Instead of exceptions, it's better to handle errors and know on what state it failed

  def monitor_summoners(_summoners) do
    #  Once fetched, all summoners will be monitored for new matches every minute for the next hour
    # When a summoner plays a new match, the match id is logged to the console, such as:
    # Summoner <summoner name> completed match <match id>

    # https://developer.riotgames.com/apis#match-v5/GET_getMatch
    # participant region is not returned, how can we know participant region?
  end

  @spec config() :: Keyword.t()
  defp config do
    Application.get_env(@app, __MODULE__)
  end
end
