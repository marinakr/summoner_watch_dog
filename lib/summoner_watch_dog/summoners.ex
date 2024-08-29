defmodule SummonerWatchDog.Summoners do
  @moduledoc false
  import Ecto.Query

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Seraphine.Connector
  alias SummonerWatchDog.Summoners.Summoner

  @limit 1000

  @spec store(binary(), binary(), binary()) :: {:ok, Summoner.t()} | {:error, Ecto.Changeset.t()}
  def store(region, puuid, name) do
    attrs = %{region: region, puuid: puuid, name: name}

    case get_by(puuid, region) do
      nil ->
        create_summoner(attrs)

      summoner ->
        update_summoner(summoner, attrs)
    end
  end

  @spec get_by(Connector.puuid(), Connector.region()) :: Summoner.t() | nil
  def get_by(puuid, region) do
    Summoner
    |> where([s], s.puuid == ^puuid and s.region == ^region)
    |> Repo.one()
  end

  @spec get_summoner(Ecto.UUID.t()) :: {:ok, Summoner.t()} | {:error, :not_found}
  def get_summoner(id) do
    case Repo.get(Summoner, id) do
      %Summoner{} = summoner -> {:ok, summoner}
      nil -> {:error, :not_found}
    end
  end

  @spec get_summoner!(Ecto.UUID.t()) :: Summoner.t()
  def get_summoner!(id), do: Repo.get!(Summoner, id)

  @spec create_summoner(map()) :: {:ok, Summoner.t()} | {:error, Ecto.Changeset.t()}
  def create_summoner(attrs) do
    %Summoner{}
    |> Summoner.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_summoner(Summoner.t(), map()) :: {:ok, Summoner.t()} | {:error, Ecto.Changeset.t()}
  def update_summoner(%Summoner{} = summoner, attrs) do
    summoner
    |> Summoner.changeset(attrs)
    |> Repo.update()
  end

  @spec change_summoner(Summoner.t(), map()) :: Ecto.Changeset.t()
  def change_summoner(%Summoner{} = summoner, attrs \\ %{}) do
    Summoner.changeset(summoner, attrs)
  end

  @spec list_summoners() :: [Summoner.t()]
  @spec list_summoners(non_neg_integer()) :: [Summoner.t()]
  @spec list_summoners(non_neg_integer(), non_neg_integer()) :: [Summoner.t()]

  def list_summoners(limit \\ @limit, offset \\ 0) do
    Summoner
    |> order_by([s], desc: s.inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end
end
