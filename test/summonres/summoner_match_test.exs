defmodule SummonerWatchDog.Matches.MatchTest do
  use SummonerWatchDog.DataCase, async: true
  alias SummonerWatchDog.Summoners.SummonerMatch

  describe "changeset/2" do
    test "successfully works for valid changeset" do
      assert %Ecto.Changeset{valid?: true} =
               SummonerMatch.changeset(%SummonerMatch{}, %{
                 puuid: gen_remote_id(),
                 match_id: gen_remote_id()
               })
    end

    test "error when missing required field" do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [match_id: {"can't be blank", [validation: :required]}]
             } =
               SummonerMatch.changeset(%SummonerMatch{}, %{
                 puuid: gen_remote_id()
               })

      assert %Ecto.Changeset{
               valid?: false,
               errors: [puuid: {"can't be blank", [validation: :required]}]
             } =
               SummonerMatch.changeset(%SummonerMatch{}, %{
                 match_id: gen_remote_id()
               })
    end

    test "unique_constraint check works" do
      match_id = gen_remote_id()

      summoner = insert(:summoner)
      insert(:summoner_match, puuid: summoner.puuid, match_id: match_id)

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  puuid:
                    {"has already been taken",
                     [
                       constraint: :unique,
                       constraint_name: "summoner_matches_puuid_match_id_index"
                     ]}
                ],
                valid?: false
              }} =
               %SummonerMatch{}
               |> SummonerMatch.changeset(%{
                 puuid: summoner.puuid,
                 match_id: match_id
               })
               |> SummonerWatchDog.Repo.insert()
    end
  end
end
