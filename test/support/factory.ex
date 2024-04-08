defmodule SummonerWatchDog.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: SummonerWatchDog.Repo

  alias SummonerWatchDog.Summoners.Summoner
  alias SummonerWatchDog.Summoners.SummonerMatch

  def gen_remote_id, do: Base.encode64(:crypto.strong_rand_bytes(78))

  def summoner_factory do
    %Summoner{
      name: "Jane Smith",
      puuid: gen_remote_id(),
      region: "br1"
    }
  end

  def summoner_match_factory do
    %SummonerMatch{match_id: gen_remote_id()}
  end
end
