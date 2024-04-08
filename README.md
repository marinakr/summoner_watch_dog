# SummonerWatchDog

**ENV**

 - RIOT_API_KEY - required, string, API Key to communicate with Riot API
 
 - LAST_MATCHES_NUMBER - optional, non negative integer, Number of matches to list summoner played, default is 5

Get last summoner names summoner played with:

```
in console, run:
$ iex -S mix

Erlang/OTP 25 [erts-13.1.5] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Compiling 2 files (.ex)
Interactive Elixir (1.14.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> SummonerWatchDog.list_summoners_played_with("br1", "DuchaGG")

      ["0Mannel", "JVAS14", "allan pvp insano", "DuchaGG", "SPANK01", "bgod má fase",
        "GordaoDoGolzin", "Loco de Breja", "CrocodiloCabelud", "SenhorDaCachaça",
        "Lciang", "Opantero", "Missrael", "Titã Mizeravão", "Hamletizinho",
        "JussiCleido66", "Luizhmpontes", "l2Defendi", "semlee", "Angelico",
        "Christian5320", "The Shepherd", "bruno9191", "ZPr9o", "Chapecoense123",
        "Dancrazy", "Na Keria", "isonOx", "TUTUTIRULIPA", "Biel gala doce",
        "SrFISICOturista", "Alemao do Forro", "xêro de fimose", "BepplerFanBoy",
        "Alumínio", "im not your ally", "Cupcat", "vitoxgameprays", "AvarezaA",
        "amilanese onion", "TeMpL4rI0", "FanaticoLoko", "NANAMI CHAN", "Toma sombra",
        "Bocal Quadrado", "SKT Xandy Trynda"]
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

** Lints **

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

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
