defmodule SummonerWatchDog.Summoners.SummonerMatch do
  @moduledoc false
  use SummonerWatchDog.Schema
  import Ecto.Changeset

  alias SummonerWatchDog.Matches.Match
  alias SummonerWatchDog.Summoners.Summoner

  @type t :: %__MODULE__{}

  schema "summoners_matches" do
    belongs_to :match, Match
    belongs_to :summoner, Summoner
  end

  @fields [:match_id, :summoner_id]
  def changeset(%__MODULE__{} = summoner_match, attrs) do
    summoner_match
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:match_id, :summoner_id])
  end
end
