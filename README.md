# SummonerWatchDog

**ENV**

 - RIOT_API_KEY - required, string, API Key to communicate with Riot API
 
 - LAST_MATCHES_NUMBER - optional, non negative integer, Number of matches to list summoner played, default is 5

There are two options to get last summoner names summoner played with:
 - Web request
 - Console

**Web**

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Export your export RIOT_API_KEY with `RIOT_API_KEY="RGAPI-YOUR-API-KEY"`

Now you can request one of to summoners in br1 region, DuchaGG

```
curl "http://localhost:4000/api/summoners/br1/DuchaGG/summoners_last_played"

["DRAGON D VAYNE","mahkiller94","Kojito","Top or Cliff","Valëntine","Hide on Tilt","Nick Boy","pirulitopipoca","DjonathaS2","rabão","LCKAZ","akuma tekina","Jurasz1","YuungBuda7k","Hasnei 007","Furtos","QuiwiKid","Ahri delle","JPrex","amaaz1ng","GastriteNervosä","king of pleyer","Pyke e meu main","DOLLY BAGUNCINHA","CarlhosNNE","OdinGoD","254814894 ","taMENSTRUANDOai","legendskillLOL","eoSmith","MIDl","Emma Robertss","thyagobm","Macunaíba","PSD Rocky","Kaminishi","CPE Blank","DuduCarregador23","Lazing","CPE Itzal","CPE Ctrl","SCHIN LATAO","Churits","Samba d Barreiro","GABRIELBESTtaric"]
```

Region `americas` will work as well:

```
curl "http://localhost:4000/api/summoners/americas/DuchaGG/summoners_last_played"



["DRAGON D VAYNE","mahkiller94","Kojito","Top or Cliff","Valëntine","Hide on Tilt","Nick Boy","pirulitopipoca","DjonathaS2","rabão","LCKAZ","akuma tekina","Jurasz1","YuungBuda7k","Hasnei 007","Furtos","QuiwiKid","Ahri delle","JPrex","amaaz1ng","GastriteNervosä","king of pleyer","Pyke e meu main","DOLLY BAGUNCINHA","CarlhosNNE","OdinGoD","254814894 ","taMENSTRUANDOai","legendskillLOL","eoSmith","MIDl","Emma Robertss","thyagobm","Macunaíba","PSD Rocky","Kaminishi","CPE Blank","DuduCarregador23","Lazing","CPE Itzal","CPE Ctrl","SCHIN LATAO","Churits","Samba d Barreiro","GABRIELBESTtaric"]
```

Output when server is working:
```
[warning] Summoner YuungBuda7k completed match BR1_2920708977
```


**Console**
```
in console, run:
$ iex -S mix

Erlang/OTP 25 [erts-13.1.5] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Compiling 2 files (.ex)
Interactive Elixir (1.14.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> SummonerWatchDog.list_summoners_played_with("br1", "DuchaGG")

["DRAGON D VAYNE","mahkiller94","Kojito","Top or Cliff","Valëntine","Hide on Tilt","Nick Boy","pirulitopipoca","DjonathaS2","rabão","LCKAZ","akuma tekina","Jurasz1","YuungBuda7k","Hasnei 007","Furtos","QuiwiKid","Ahri delle","JPrex","amaaz1ng","GastriteNervosä","king of pleyer","Pyke e meu main","DOLLY BAGUNCINHA","CarlhosNNE","OdinGoD","254814894 ","taMENSTRUANDOai","legendskillLOL","eoSmith","MIDl","Emma Robertss","thyagobm","Macunaíba","PSD Rocky","Kaminishi","CPE Blank","DuduCarregador23","Lazing","CPE Itzal","CPE Ctrl","SCHIN LATAO","Churits","Samba d Barreiro","GABRIELBESTtaric"]
```

**Testing**

```
$ mix test
```

Test modules are most neccessary
 - `test/oban/summoners_worker_test.exs`
 - `test/seraphine/connector_test.exs` 
 - `test/summoner_watch_dog_test.exs`  

 ```
 MIX_ENV=test mix coveralls

 Randomized with seed 912015
----------------
COV    FILE                                        LINES RELEVANT   MISSED
 77.7% lib/summoner_watch_dog.ex                      93       18        4
 80.0% lib/summoner_watch_dog/application.ex          36        5        1
 95.0% lib/summoner_watch_dog/oban/summoner_wor      109       20        1
  0.0% lib/summoner_watch_dog/repo.ex                  5        0        0
  0.0% lib/summoner_watch_dog/schema.ex               10        0        0
 87.8% lib/summoner_watch_dog/seraphine/connect      150       41        5
100.0% lib/summoner_watch_dog/summoner_matches.       34        6        0
100.0% lib/summoner_watch_dog/summoners.ex            32        6        0
100.0% lib/summoner_watch_dog/summoners/summone       28        2        0
100.0% lib/summoner_watch_dog/summoners/summone       26        2        0
100.0% lib/summoner_watch_dog_web.ex                  65        2        0
100.0% lib/summoner_watch_dog_web/controllers/e       21        4        0
100.0% lib/summoner_watch_dog_web/controllers/s       16        4        0
  0.0% lib/summoner_watch_dog_web/endpoint.ex         47        0        0
100.0% lib/summoner_watch_dog_web/router.ex           15        2        0
 80.0% lib/summoner_watch_dog_web/telemetry.ex        92        5        1
100.0% test/support/conn_case.ex                      38        2        0
 57.1% test/support/data_case.ex                      62        7        3
100.0% test/support/factory.ex                        21        3        0
[TOTAL]  88.3%
---------------

```

**Code quality (linter, credo, etc)**

```
$ mix quality

Starting Dialyzer
[
  check_plt: false,
  init_plt: '/home/maryna/projects/summoner_watch_dog/_build/dev/dialyxir_erlang-25.2.3_elixir-1.14.3_deps-dev.plt',
  files: ['/home/maryna/projects/summoner_watch_dog/_build/dev/lib/summoner_watch_dog/ebin/Elixir.SummonerWatchDog.Application.beam',
   '/home/maryna/projects/summoner_watch_dog/_build/dev/lib/summoner_watch_dog/ebin/Elixir.SummonerWatchDog.Oban.SummonerWorker.beam',
   '/home/maryna/projects/summoner_watch_dog/_build/dev/lib/summoner_watch_dog/ebin/Elixir.SummonerWatchDog.Repo.beam',
   '/home/maryna/projects/summoner_watch_dog/_build/dev/lib/summoner_watch_dog/ebin/Elixir.SummonerWatchDog.Schema.beam',
   '/home/maryna/projects/summoner_watch_dog/_build/dev/lib/summoner_watch_dog/ebin/Elixir.SummonerWatchDog.Seraphine.Connector.beam',
   ...],
  warnings: [:unknown]
]
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m2.75s
done (passed successfully)

```