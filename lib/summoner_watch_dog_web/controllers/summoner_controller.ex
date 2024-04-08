defmodule SummonerWatchDogWeb.SummonerController do
  @moduledoc false
  use SummonerWatchDogWeb, :controller

  def summoners_last_played(conn, %{"region" => region, "name" => summoner_name}) do
    case SummonerWatchDog.list_summoners_played_with(region, summoner_name) do
      summoner_names when is_list(summoner_names) ->
        json(conn, summoner_names)

      {:error, error} when is_atom(error) ->
        conn
        |> Plug.Conn.resp(400, "Error - #{error}")
        |> Plug.Conn.send_resp()
    end
  end
end
