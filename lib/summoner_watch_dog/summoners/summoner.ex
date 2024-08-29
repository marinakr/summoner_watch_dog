defmodule SummonerWatchDog.Summoners.Summoner do
  @moduledoc false
  use SummonerWatchDog.Schema
  import Ecto.Changeset

  alias SummonerWatchDog.Summoners.SummonerMatch

  @type t :: %__MODULE__{}
  @type id :: Ecto.UUID.t()

  schema "summoners" do
    field :name
    field :puuid
    field :region
    has_many :summoner_matches, SummonerMatch, references: :puuid, foreign_key: :puuid

    timestamps()
  end

  @fields [:name, :puuid, :region]
  @required_fields [:puuid]

  def changeset(%__MODULE__{} = summoner, attrs) do
    summoner
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:puuid])
  end
end
