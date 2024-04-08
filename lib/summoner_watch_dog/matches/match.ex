defmodule SummonerWatchDog.Matches.Match do
  @moduledoc false
  use SummonerWatchDog.Schema
  import Ecto.Changeset

  alias SummonerWatchDog.Summoners.SummonerMatch

  @type t :: %__MODULE__{}

  schema "matches" do
    field :remote_match_id
    # Mb consider to use Ecto.Enum, aka Ecto.Enum, values: [:americas, :asia, :europe]
    field :routing
    field :game_end, :utc_datetime

    timestamps()

    has_many :summoner_matches, SummonerMatch
    has_many :summoners, through: [:summoner_matches, :summoner]
  end

  @fields [:remote_match_id, :routing, :game_end]
  @required_fields [:remote_match_id, :routing]

  def changeset(%__MODULE__{} = match, attrs) do
    match
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:remote_match_id, :routing])
  end
end
