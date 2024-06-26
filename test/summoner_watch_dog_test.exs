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
               "America Player 1",
               "America Player 4",
               "America Player 5",
               "America Player 6",
               "America Player 2",
               "America Player 3"
             ] == names

      for {puuid, name} <- [
            {"p1", "America Player 1"},
            {"p4", "America Player 4"},
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
               "America Player 1",
               "America Player 4",
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
  end
end
