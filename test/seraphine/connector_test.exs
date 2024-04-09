defmodule SummonerWatchDog.Seraphine.ConnectorTest do
  @moduledoc """
  Mocks for riot
  """
  use SummonerWatchDog.DataCase, async: false
  use Mimic

  alias SummonerWatchDog.Seraphine.Connector

  describe "get_puuid_by_name/2" do
    test "can fetch a user" do
      puuid = gen_remote_id()
      region = "br1"

      expect(Seraphine.API.RiotAPIBase, :get, fn _, _ ->
        {:ok, %{status_code: 200, body: ~s({"puuid": "#{puuid}"}), headers: []}}
      end)

      assert {:ok, ^puuid} = Connector.get_puuid_by_name(region, "Summoner Top 1")
    end

    test "handles Seraphine raised error" do
      expect(Seraphine.API.RiotAPIBase, :get, fn _, _ ->
        {:ok, %{status_code: 400, body: "Bad request", headers: []}}
      end)

      assert {:error, :get_puuid_failed} = Connector.get_puuid_by_name("br1", "Summoner Top 1")
    end

    test "handles Seraphine Api raised error" do
      assert {:error, :get_puuid_failed} =
               Connector.get_puuid_by_name("no_such_region", "Summoner Top 1")
    end
  end

  describe "list_summoner_matches/2" do
    test "works for all regions" do
      puuid = gen_remote_id()

      expect(Seraphine.API.RiotAPIBase, :get, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body:
               ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004", "BR1_2919772367", "BR1_2919749258"]),
             headers: []
           }}
      end)

      assert {:ok,
              [
                "BR1_2919896148",
                "BR1_2919892164",
                "BR1_2919801004",
                "BR1_2919772367",
                "BR1_2919749258"
              ]} = Connector.list_summoner_matches("br1", puuid, 5)
    end
  end

  describe "list_matches_participants/2" do
    test "fetches summonres summoner played with" do
      region = "br1"

      expect(Seraphine.API.RiotAPIBase, :get, 4, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004"]),
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
                     %{puuid: "p1", summonerName: "America Player 1"},
                     %{puuid: "p9", summonerName: "America Player 9"}
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
      end)

      assert {:ok, playes} = Connector.list_matches_participants(gen_remote_id(), region, 5)

      assert [
               %{puuid: "p1", summoner_name: "America Player 1"},
               %{puuid: "p2", summoner_name: "America Player 2"},
               %{puuid: "p3", summoner_name: "America Player 3"},
               %{puuid: "p4", summoner_name: "America Player 4"},
               %{puuid: "p5", summoner_name: "America Player 5"},
               %{puuid: "p6", summoner_name: "America Player 6"},
               %{puuid: "p9", summoner_name: "America Player 9"}
             ] = Enum.sort_by(playes, & &1.puuid)
    end

    test "fails when get matches for region" do
      expect(Seraphine.API.RiotAPIBase, :get, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 403, body: ~s(Token expired), headers: []}}
      end)

      assert {:error, :list_matches_failed} =
               Connector.list_matches_participants(gen_remote_id(), "br1", 5)
    end

    test "fails when get participants for one of matches" do
      expect(Seraphine.API.RiotAPIBase, :get, 3, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919896148", "BR1_2919749258"]), headers: []}}

        # match info
        "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919896148" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body:
               Jason.encode!(%{
                 info: %{
                   participants: [
                     %{puuid: "p1", summonerName: "America Player 1"},
                     %{puuid: "p9", summonerName: "Europe Player 9"}
                   ]
                 }
               }),
             headers: []
           }}

        "https://americas.api.riotgames.com/lol/match/v5/matches/BR1_2919749258" <> _, _ ->
          {:ok,
           %{
             status_code: 410,
             body: "Gone",
             headers: []
           }}
      end)

      assert {:error, :list_match_participants_failed} =
               Connector.list_matches_participants(gen_remote_id(), "br1", 5)
    end
  end
end
