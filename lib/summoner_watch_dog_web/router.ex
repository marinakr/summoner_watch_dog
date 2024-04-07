defmodule SummonerWatchDogWeb.Router do
  use SummonerWatchDogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SummonerWatchDogWeb do
    pipe_through :api
  end
end
