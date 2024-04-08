defmodule SummonerWatchDog.Repo.Migrations.CreateSummonersAndMatches do
  use Ecto.Migration

  def change do
    create table(:summoners) do
      add :name, :text
      add :puuid, :string, null: false
      add :region, :string

      timestamps()
    end

    create unique_index(:summoners, [:puuid, :region])
    create index(:summoners, [:puuid])

    create table(:matches) do
      add :remote_match_id, :string, null: false
      add :routing, :string

      add :game_end, :utc_datetime
    end

    create unique_index(:matches, [:remote_match_id, :routing])

    create table(:summoners_matches) do
      add :summoner_id, references(:summoners, type: :uuid), null: false
      add :match_id, references(:matches, type: :uuid), null: false
    end

    create unique_index(:summoners_matches, [:summoner_id, :match_id])
  end
end
