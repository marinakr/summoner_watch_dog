Mimic.copy(Seraphine.API.RiotAPIBase)
{:ok, _} = Application.ensure_all_started(:mimic)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SummonerWatchDog.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)
