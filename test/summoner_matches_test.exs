defmodule SummonerWatchDog.SummonerMatchesTest do
  use SummonerWatchDog.DataCase, async: true

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.SummonerMatches
  alias SummonerWatchDog.Summoners.SummonerMatch

  @match_id gen_remote_id()
  @puuid gen_remote_id()

  describe "store/1" do
    test "creates new match" do
      summoner = insert(:summoner)
      assert {:ok, %SummonerMatch{id: id}} = SummonerMatches.store(summoner.puuid, @match_id)

      assert Repo.get(SummonerMatch, id)
    end

    test "summoner match exists" do
      summoner = insert(:summoner)
      %{id: id} = insert(:summoner_match, puuid: summoner.puuid, match_id: @match_id)

      assert {:ok, %SummonerMatch{id: ^id}} = SummonerMatches.store(summoner.puuid, @match_id)
    end
  end

  describe "get_by/1" do
    test "returns summoner match" do
      summoner = insert(:summoner, puuid: @puuid)

      %{id: match_id} = insert(:summoner_match, puuid: summoner.puuid, match_id: @match_id)

      assert %SummonerMatch{id: ^match_id} = SummonerMatches.get_by(summoner.puuid, @match_id)
    end

    test "no summoner match found" do
      refute SummonerMatches.get_by(@puuid, @match_id)
    end
  end
end
