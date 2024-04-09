defmodule SummonerWatchDogWeb.SummonerControllerTest do
  use SummonerWatchDogWeb.ConnCase, async: true
  import Mimic
  @puuid "ABCD1234567890"

  test "returns summoners", %{conn: conn} do
    expect(
      Seraphine.API.RiotAPIBase,
      :get,
      fn "https://br1.api.riotgames.com/lol/summoner/v4/summoners/by-name/DuchaGG", _ ->
        {:ok, %{status_code: 200, body: ~s({"puuid": "#{@puuid}"}), headers: []}}
      end
    )

    expect(Seraphine.API.RiotAPIBase, :get, 6, fn
      "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/#{@puuid}" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004", "BR1_2919772367", "BR1_2919749258"]),
           headers: []
         }}

      # match info
      "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919896148" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             Jason.encode!(%{
               info: %{
                 participants: [
                   %{puuid: "p1", summonerName: "America Player 1"}
                 ]
               }
             }),
           headers: []
         }}

      "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919892164" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             Jason.encode!(%{
               info: %{
                 participants: [
                   %{puuid: "p2", summonerName: "America Player 2"},
                   %{puuid: "p3", summonerName: "America Player 3"}
                 ]
               }
             }),
           headers: []
         }}

      "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919801004" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             Jason.encode!(%{
               info: %{
                 participants: [
                   %{puuid: "p4", summonerName: "America Player 4"},
                   %{puuid: "p5", summonerName: "America Player 5"},
                   %{puuid: "p6", summonerName: "America Player 6"}
                 ]
               }
             }),
           headers: []
         }}

      "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919772367" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             Jason.encode!(%{
               info: %{
                 participants: [
                   %{puuid: "p4", summonerName: "America Player 4"}
                 ]
               }
             }),
           headers: []
         }}

      "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919749258" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body:
             Jason.encode!(%{
               info: %{
                 participants: [
                   %{puuid: "p1", summonerName: "America Player 1"}
                 ]
               }
             }),
           headers: []
         }}
    end)

    assert [
             "America Player 1",
             "America Player 4",
             "America Player 5",
             "America Player 6",
             "America Player 2",
             "America Player 3"
           ] =
             conn
             |> get(~p"/api/summoners/br1/DuchaGG/summoners_last_played")
             |> json_response(200)
  end

  test "can't find a user", %{conn: conn} do
    expect(Seraphine.API.RiotAPIBase, :get, fn _, _ ->
      {:ok, %{status_code: 404, body: ~s(No such played), headers: []}}
    end)

    assert "Error - get_puuid_failed" =
             conn
             |> get(~p"/api/summoners/br1/DuchaGG/summoners_last_played")
             |> response(400)
  end
end
