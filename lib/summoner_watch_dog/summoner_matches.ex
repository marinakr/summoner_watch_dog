defmodule SummonerWatchDog.SummonerMatches do
  @moduledoc false
  import Ecto.Query

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Summoners.SummonerMatch

  require Logger

  @limit 1000

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

  @spec get_summoner_match(Ecto.UUID.t()) :: {:ok, SummonerMatch.t()} | {:error, :not_found}
  def get_summoner_match(id) do
    case Repo.get(SummonerMatch, id) do
      %SummonerMatch{} = match -> {:ok, match}
      nil -> {:error, :not_found}
    end
  end

  @spec get_summoner_match!(Ecto.UUID.t()) :: SummonerMatch.t()
  def get_summoner_match!(id), do: Repo.get!(SummonerMatch, id)

  @spec create_summoner_match(map()) :: {:ok, SummonerMatch.t()} | {:error, Ecto.Changeset.t()}
  def create_summoner_match(attrs) do
    %SummonerMatch{}
    |> SummonerMatch.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_summoner_match(SummonerMatch.t(), map()) ::
          {:ok, SummonerMatch.t()} | {:error, Ecto.Changeset.t()}
  def update_summoner_match(%SummonerMatch{} = match, attrs) do
    match
    |> SummonerMatch.changeset(attrs)
    |> Repo.update()
  end

  @spec change_summoner_match(SummonerMatch.t(), map()) :: Ecto.Changeset.t()
  def change_summoner_match(%SummonerMatch{} = match, attrs \\ %{}) do
    SummonerMatch.changeset(match, attrs)
  end

  @spec list_summoner_matches() :: [SummonerMatch.t()]
  @spec list_summoner_matches(non_neg_integer()) :: [SummonerMatch.t()]
  @spec list_summoner_matches(non_neg_integer(), non_neg_integer()) :: [SummonerMatch.t()]

  def list_summoner_matches(limit \\ @limit, offset \\ 0) do
    SummonerMatch
    |> order_by([s], desc: s.inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end
end
