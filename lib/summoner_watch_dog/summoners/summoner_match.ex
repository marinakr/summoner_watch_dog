defmodule SummonerWatchDog.Summoners.SummonerMatch do
  @moduledoc false
  use SummonerWatchDog.Schema
  import Ecto.Changeset

  alias SummonerWatchDog.Summoners.Summoner

  @type t :: %__MODULE__{}

  schema "summoner_matches" do
    field :match_id
    field :puuid
    belongs_to :summoner, Summoner, references: :puuid, define_field: false

    timestamps()
  end

  @fields [:puuid, :match_id]

  def changeset(%__MODULE__{} = match, attrs) do
    match
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:puuid, :match_id])
  end
end
