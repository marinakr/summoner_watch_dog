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

      expect(Seraphine.API.RiotAPIBase, :get, 4, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004"]),
             headers: []
           }}

        "https://asia.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919772367"]), headers: []}}

        "https://europe.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919749258"]), headers: []}}

        "https://sea.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s([]), headers: []}}
      end)

      assert {:ok,
              [
                "BR1_2919749258",
                "BR1_2919772367",
                "BR1_2919896148",
                "BR1_2919892164",
                "BR1_2919801004"
              ]} = Connector.list_summoner_matches(puuid, 5)
    end
  end

  describe "list_matches_participants/2" do
    test "fetches summonres summoner played with" do
      expect(Seraphine.API.RiotAPIBase, :get, 9, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004"]),
             headers: []
           }}

        "https://asia.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919772367"]), headers: []}}

        "https://europe.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919749258"]), headers: []}}

        "https://sea.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s([]), headers: []}}

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
                     %{puuid: "p6", summonerName: "America Player 6"},
                     %{puuid: "p7", summonerName: "Asia Player 7"}
                   ]
                 }
               }),
             headers: []
           }}

        "https://asia.api.riotgames.com/lol/match/v5/matches/BR1_2919772367" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body:
               Jason.encode!(%{
                 info: %{
                   participants: [
                     %{puuid: "p4", summonerName: "America Player 4"},
                     %{puuid: "p7", summonerName: "Asia Player 7"},
                     %{puuid: "p8", summonerName: "Asia Player 8"}
                   ]
                 }
               }),
             headers: []
           }}

        "https://europe.api.riotgames.com/lol/match/v5/matches/BR1_2919749258" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body:
               Jason.encode!(%{
                 info: %{
                   participants: [
                     %{puuid: "p7", summonerName: "Asia Player 7"},
                     %{puuid: "p9", summonerName: "Europe Player 9"},
                     %{puuid: "p10", summonerName: "Europe Player 10"},
                     %{puuid: "p1", summonerName: "America Player 1"}
                   ]
                 }
               }),
             headers: []
           }}
      end)

      assert {:ok, playes} = Connector.list_matches_participants(gen_remote_id(), 5)

      assert [
               %{puuid: "p1", summoner_name: "America Player 1"},
               %{puuid: "p10", summoner_name: "Europe Player 10"},
               %{puuid: "p2", summoner_name: "America Player 2"},
               %{puuid: "p3", summoner_name: "America Player 3"},
               %{puuid: "p4", summoner_name: "America Player 4"},
               %{puuid: "p5", summoner_name: "America Player 5"},
               %{puuid: "p6", summoner_name: "America Player 6"},
               %{puuid: "p7", summoner_name: "Asia Player 7"},
               %{puuid: "p8", summoner_name: "Asia Player 8"},
               %{puuid: "p9", summoner_name: "Europe Player 9"}
             ] = Enum.sort_by(playes, & &1.puuid)
    end

    test "fails when get matches for one of regions" do
      expect(Seraphine.API.RiotAPIBase, :get, 2, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004"]),
             headers: []
           }}

        _, _ ->
          {:ok, %{status_code: 403, body: ~s(Token expired), headers: []}}
      end)

      assert {:error, :list_match_participants_failed} =
               Connector.list_matches_participants(gen_remote_id(), 5)
    end

    test "fails when get participants for one of matches" do
      expect(Seraphine.API.RiotAPIBase, :get, 4, fn
        "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919896148"]), headers: []}}

        "https://asia.api.riotgames.com/lol/match/v5/matches/by-puuid/" <> _, _ ->
          {:ok, %{status_code: 200, body: ~s(["BR1_2919749258"]), headers: []}}

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

        "https://asia.api.riotgames.com/lol/match/v5/matches/BR1_2919749258" <> _, _ ->
          {:ok,
           %{
             status_code: 410,
             body: "Gone",
             headers: []
           }}
      end)

      assert {:error, :list_match_participants_failed} =
               Connector.list_matches_participants(gen_remote_id(), 5)
    end
  end
end
