defmodule SummonerWatchDog.Summoners do
  @moduledoc false
  import Ecto.Query

  alias SummonerWatchDog.Repo
  alias SummonerWatchDog.Seraphine.Connector
  alias SummonerWatchDog.Summoners.Summoner

  @spec store(binary(), binary(), binary()) :: {:ok, Summoner.t()} | {:error, Ecto.Changeset.t()}
  def store(region, puuid, name) do
    attrs = %{region: region, puuid: puuid, name: name}

    case get_by(puuid, region) do
      nil ->
        %Summoner{}
        |> Summoner.changeset(attrs)
        |> Repo.insert()

      summoner ->
        summoner
        |> Summoner.changeset(attrs)
        |> Repo.update()
    end
  end

  @spec get_by(Connector.puuid(), Connector.region()) :: Summoner.t() | nil
  def get_by(puuid, region) do
    Summoner
    |> where([s], s.puuid == ^puuid and s.region == ^region)
    |> Repo.one()
  end
end
