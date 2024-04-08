defmodule SummonerWatchDogWeb.SummonerController do
  @moduledoc false
  use SummonerWatchDogWeb, :controller

  def summoners_last_played(conn, %{region: region, name: summoner_name}) do
    case SummonerWatchDog.list_summoners_played_with(region, summoner_name) do
      summoner_names when is_list(summoner_names) ->
        render(conn, "summoners_last_played.json", %{summoner_names: summoner_names})

      {:error, message} ->
        render(conn, "400.json", %{message: message})
    end
  end
end
