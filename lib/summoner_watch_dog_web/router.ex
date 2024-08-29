defmodule SummonerWatchDogWeb.Router do
  use SummonerWatchDogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SummonerWatchDogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SummonerWatchDogWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", SummonerWatchDogWeb do
    pipe_through :api

    get "/summoners/:region/:name/summoners_last_played",
        SummonerController,
        :summoners_last_played
  end

  scope "/live", SummonerWatchDogWeb do
    pipe_through :browser

    live "/summoners/new", SummonerLive.Index, :new
    live "/summoners/:id/edit", SummonerLive.Index, :edit
    live "/summoners/:id", SummonerLive.Show, :show
    live "/summoners/:id/show/edit", SummonerLive.Show, :edit
    live "/", SummonerLive.Index, :index

    live "/summoner_matches/new", SummonerMatchLive.Index, :new
    live "/summoner_matches/:id/edit", SummonerMatchLive.Index, :edit
    live "/summoner_matches/:id", SummonerMatchLive.Show, :show
    live "/summoner_matches/:id/show/edit", SummonerMatchLive.Show, :edit
    live "/summoner_matches", SummonerMatchLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SummonerWatchDogWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:summoner_watch_dog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SummonerWatchDogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
