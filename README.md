# SummonerWatchDog

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

ENVs

**NAME | REQUIRED / OPTIONAL | TYPE | DESCRIPTION**

RIOT_API_KEY | required | string | API Key to communicate with Riot API

LAST_MATCHES_NUMBER | optional | non negative integer | number of matches to list summoner played, default is 5

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
