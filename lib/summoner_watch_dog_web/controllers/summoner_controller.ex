defmodule SummonerWatchDogWeb.SummonerController do
  @moduledoc false
  use SummonerWatchDogWeb, :controller

  def summoners_last_played(conn, %{region: region, name: summoner_name}) do
    summoner_names = SummonerWatchDog.list_summoners_played_with(region, summoner_name)
    render(conn, :summoners_last_played, summoner_names: summoner_names)
  end
end
