defmodule SummonerWatchDogWeb.SummonerView do
  @moduledoc false
  use SummonerWatchDogWeb, :controller

  def render("summoners_last_played.json", %{summoner_names: summoner_names}) do
    summoner_names
  end
end
