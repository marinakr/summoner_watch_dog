defmodule SummonerWatchDog.Repo do
  use Ecto.Repo,
    otp_app: :summoner_watch_dog,
    adapter: Ecto.Adapters.Postgres
end
