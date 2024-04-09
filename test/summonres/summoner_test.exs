defmodule SummonerWatchDog.Summoners.SummonerTest do
  use SummonerWatchDog.DataCase, async: true
  alias SummonerWatchDog.Summoners.Summoner

  describe "changeset/2" do
    test "successfully works for valid changeset" do
      assert %Ecto.Changeset{valid?: true} =
               Summoner.changeset(%Summoner{}, %{
                 name: "Summoner Top 1",
                 puuid: gen_remote_id(),
                 region: "br1"
               })
    end

    test "error when missing required field" do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [puuid: {"can't be blank", [validation: :required]}]
             } =
               Summoner.changeset(%Summoner{}, %{
                 name: "Summoner Top 1"
               })
    end

    test "unique_constraint check works" do
      puuid = gen_remote_id()
      region = "br1"

      insert(:summoner, puuid: puuid, region: region)

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  puuid:
                    {"has already been taken",
                     [constraint: :unique, constraint_name: "summoners_puuid_index"]}
                ],
                valid?: false
              }} =
               %Summoner{}
               |> Summoner.changeset(%{
                 name: "Summoner Top 1",
                 puuid: puuid,
                 region: region
               })
               |> SummonerWatchDog.Repo.insert()
    end
  end
end
