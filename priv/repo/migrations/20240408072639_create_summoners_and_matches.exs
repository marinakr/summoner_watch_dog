defmodule SummonerWatchDog.Repo.Migrations.CreateSummonersAndMatches do
  use Ecto.Migration

  def change do
    create table(:summoners) do
      add :name, :text
      add :puuid, :string, null: false
      add :region, :string

      timestamps()
    end

    create unique_index(:summoners, [:puuid])

    create table(:summoner_matches) do
      add :puuid,
          references(:summoners,
            type: :string,
            column: :puuid,
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :match_id, :string, null: false

      timestamps()
    end

    create unique_index(:summoner_matches, [:puuid, :match_id])
  end
end
