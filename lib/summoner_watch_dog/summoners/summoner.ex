defmodule SummonerWatchDog.Summoners.Summoner do
  @moduledoc false
  use SummonerWatchDog.Schema
  import Ecto.Changeset

  alias SummonerWatchDog.Summoners.SummonerMatch

  @type t :: %__MODULE__{}

  schema "summoners" do
    field :name
    field :puuid

    # Mb use Ecto.Enum, values: [:br1, :eun1, :euw1, :jp1, :kr, :la1, :la2, :na1, :oc1, :tr1, :ru] later
    field :region

    has_many :summoner_matches, SummonerMatch
    has_many :matches, through: [:summoner_matches, :match]

    timestamps()
  end

  @fields [:name, :puuids, :region]
  @required_fields [:puuids, :region]

  def changeset(%__MODULE__{} = summoner, attrs) do
    summoner
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:puuid, :region])
  end
end
