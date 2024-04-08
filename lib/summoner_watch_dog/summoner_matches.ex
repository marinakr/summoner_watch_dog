defmodule SummonerWatchDog.SummonerMatches do
  @moduledoc false
  import Ecto.Query

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Summoners.SummonerMatch

  require Logger

  @spec store(binary(), binary()) ::
          {:ok, SummonerMatch.t()} | {:error, Ecto.Changeset.t()}
  def store(puuid, match_id) do
    attrs = %{puuid: puuid, match_id: match_id}

    case get_by(puuid, match_id) do
      nil ->
        %SummonerMatch{}
        |> SummonerMatch.changeset(attrs)
        |> Repo.insert()

      match ->
        # no need to update for now, there two uniq field
        {:ok, match}
    end
  end

  @spec get_by(binary(), binary()) :: SummonerMatch.t() | nil
  def get_by(puuid, match_id) do
    SummonerMatch
    |> where([sm], sm.puuid == ^puuid)
    |> where([sm], sm.match_id == ^match_id)
    |> Repo.one()
  end
end
