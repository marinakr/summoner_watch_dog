defmodule SummonerWatchDogWeb.SummonerView do
  @moduledoc false

  def render(:summoners_last_played, %{summoner_names: summoner_names}) do
    summoner_names
  end
end
