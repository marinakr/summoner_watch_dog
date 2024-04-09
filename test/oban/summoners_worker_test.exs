defmodule SummonerWatchDog.Oban.SummonersWorkerTest do
  use SummonerWatchDog.DataCase, async: false

  alias SummonerWatchDog.Oban.SummonerWorker
  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Summoners
  alias SummonerWatchDog.Summoners.Summoner
  alias SummonerWatchDog.Summoners.SummonerMatch

  import Mimic

  @puuid gen_remote_id()
  @region "br1"
  @name "Summoner A"

  describe "enqueue_store/1" do
    test "creates job to create summoner asynchronously" do
      assert :ok = SummonerWorker.enqueue_store(@name, @region, @puuid)

      assert_enqueued(
        worker: SummonerWorker,
        args: %{
          "puuid" => @puuid,
          "region" => @region,
          "name" => @name,
          "action" => "store"
        }
      )
    end
  end

  describe "perform/1" do
    test "ignores invalid args" do
      job = Oban.insert!(SummonerWorker.new(%{}))

      log =
        capture_log(fn ->
          assert :ok = SummonerWorker.perform(job)
        end)

      error_log = "SummonerWorker job #{job.id} ignored"
      assert log =~ error_log
    end

    test "stores summoner" do
      job =
        Oban.insert!(
          SummonerWorker.new(%{
            "action" => "store",
            "puuid" => @puuid,
            "region" => @region,
            "name" => @name
          })
        )

      assert {:ok, _} = SummonerWorker.perform(job)
      assert %Summoner{} = Summoners.get_by(@puuid, @region)
    end

    test "runs sync_matches for summoner" do
      assert [] = Repo.all(SummonerMatch)
      summoner = insert(:summoner)

      job =
        Oban.insert!(
          SummonerWorker.new(%{
            "action" => "sync_matches",
            "puuid" => summoner.puuid,
            "name" => summoner.name
          })
        )

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

      log =
        capture_log(fn ->
          assert :ok = SummonerWorker.perform(job)
        end)

      assert log =~ "Summoner Jane Smith completed match BR1_2919896148"
      assert log =~ "Summoner Jane Smith completed match BR1_2919892164"
      assert log =~ "Summoner Jane Smith completed match BR1_2919801004"
      assert log =~ "Summoner Jane Smith completed match BR1_2919772367"
      assert log =~ "Summoner Jane Smith completed match BR1_2919749258"

      assert [_, _, _, _, _] = Repo.all(SummonerMatch)
    end

    test "cronjob sync_matches creates new job for each summoner to sync matches" do
      job = Oban.insert!(SummonerWorker.new(%{"action" => "sync_matches"}))

      for i <- 0..5, do: insert(:summoner, puuid: "puuid-#{i}", name: "Summoner #{i}")

      assert :ok = SummonerWorker.perform(job)

      for i <- 0..5 do
        assert_enqueued(
          worker: SummonerWorker,
          args: %{
            "action" => "sync_matches",
            "puuid" => "puuid-#{i}",
            "name" => "Summoner #{i}"
          }
        )
      end
    end
  end
end
