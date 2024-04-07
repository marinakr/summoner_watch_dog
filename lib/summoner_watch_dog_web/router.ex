defmodule SummonerWatchDogWeb.Router do
  use SummonerWatchDogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SummonerWatchDogWeb do
    pipe_through :api

    get "/summoners/:region/:name/summoners_last_played",
        SummonerController,
        :summoners_last_played
  end
end
