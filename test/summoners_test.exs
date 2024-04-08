defmodule SummonerWatchDog.SummonersTest do
  use SummonerWatchDog.DataCase, async: true

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Summoners
  alias SummonerWatchDog.Summoners.Summoner

  @puuid gen_remote_id()
  @region "br1"
  @name "player A"

  describe "store/1" do
    test "creates new summoner" do
      assert {:ok, %Summoner{id: id}} = Summoners.store(@region, @puuid, @name)
      assert %Summoner{region: @region, puuid: @puuid, name: @name} = Repo.get(Summoner, id)
    end

    test "updates summoner" do
      %{id: summoner_id} = insert(:summoner, region: @region, puuid: @puuid, name: "player 1")
      assert {:ok, %Summoner{id: ^summoner_id}} = Summoners.store(@region, @puuid, "player 2")

      assert %Summoner{region: @region, puuid: @puuid, name: "player 2"} =
               Repo.get(Summoner, summoner_id)
    end
  end

  describe "get_by/1" do
    test "returns summoner" do
      %{id: summoner_id} = insert(:summoner, region: @region, puuid: @puuid)
      assert %Summoner{id: ^summoner_id} = Summoners.get_by(@puuid, @region)
    end

    test "no summoner found" do
      refute Summoners.get_by(@puuid, @region)
    end
  end
end
