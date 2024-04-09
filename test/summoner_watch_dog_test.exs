defmodule SummonerWatchDogTest do
  use SummonerWatchDog.DataCase, async: false
  use Mimic

  @puuid gen_remote_id()
  @region "br1"
  @name "Summoner 1"

  describe "list_summoners_played_with/1" do
    test "invalid region" do
      assert {:error, :invalid_region} =
               SummonerWatchDog.list_summoners_played_with("no such region", @name)
    end

    test "works for region (br1)" do
      expect(
        Seraphine.API.RiotAPIBase,
        :get,
        fn "https://br1.api.riotgames.com/lol/summoner/v4/summoners/by-name/Summoner%201", _ ->
          {:ok, %{status_code: 200, body: ~s({"puuid": "#{@puuid}"}), headers: []}}
        end
      )

      expect_match_participants()

      names = SummonerWatchDog.list_summoners_played_with(@region, @name)

      assert [
               "Asia Player 7",
               "Europe Player 9",
               "Europe Player 10",
               "America Player 1",
               "America Player 4",
               "Asia Player 8",
               "America Player 5",
               "America Player 6",
               "America Player 2",
               "America Player 3"
             ] == names

      for {puuid, name} <- [
            {"p7", "Asia Player 7"},
            {"p9", "Europe Player 9"},
            {"p10", "Europe Player 10"},
            {"p1", "America Player 1"},
            {"p4", "America Player 4"},
            {"p8", "Asia Player 8"},
            {"p5", "America Player 5"},
            {"p6", "America Player 6"},
            {"p2", "America Player 2"},
            {"p3", "America Player 3"}
          ] do
        assert_enqueued(
          worker: SummonerWatchDog.Oban.SummonerWorker,
          args: %{
            "action" => "store",
            "puuid" => puuid,
            "name" => name
          }
        )
      end
    end

    test "works for routing (americas)" do
      expect(Seraphine.API.RiotAPIBase, :get, 2, fn
        "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/Summoner%201", _ ->
          {:ok, %{status_code: 404, body: ~s(Not Found), headers: []}}

        "https://br1.api.riotgames.com/lol/summoner/v4/summoners/by-name/Summoner%201", _ ->
          {:ok, %{status_code: 200, body: ~s({"puuid": "#{@puuid}"}), headers: []}}
      end)

      expect_match_participants()

      assert [
               "Asia Player 7",
               "Europe Player 9",
               "Europe Player 10",
               "America Player 1",
               "America Player 4",
               "Asia Player 8",
               "America Player 5",
               "America Player 6",
               "America Player 2",
               "America Player 3"
             ] == SummonerWatchDog.list_summoners_played_with("americas", @name)
    end

    test "user not found for americas" do
      expect(Seraphine.API.RiotAPIBase, :get, 4, fn _, _ ->
        {:ok, %{status_code: 404, body: ~s(Not Found), headers: []}}
      end)

      assert {:error, :not_found} = SummonerWatchDog.list_summoners_played_with("americas", @name)
    end
  end

  defp expect_match_participants do
    expect(Seraphine.API.RiotAPIBase, :get, 9, fn
      "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/#{@puuid}" <> _, _ ->
        {:ok,
         %{
           status_code: 200,
           body: ~s(["BR1_2919896148", "BR1_2919892164", "BR1_2919801004"]),
           headers: []
         }}

      "https://asia.api.riotgames.com/lol/match/v5/matches/by-puuid/#{@puuid}" <> _, _ ->
        {:ok, %{status_code: 200, body: ~s(["BR1_2919772367"]), headers: []}}

      "https://europe.api.riotgames.com/lol/match/v5/matches/by-puuid/#{@puuid}" <> _, _ ->
        {:ok, %{status_code: 200, body: ~s(["BR1_2919749258"]), headers: []}}

      "https://sea.api.riotgames.com/lol/match/v5/matches/by-puuid/#{@puuid}" <> _, _ ->
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
  end
end
