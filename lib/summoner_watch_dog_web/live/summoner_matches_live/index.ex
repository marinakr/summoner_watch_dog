defmodule SummonerWatchDogWeb.SummonerMatchLive.Index do
  use SummonerWatchDogWeb, :live_view

  alias SummonerWatchDog.SummonerMatches
  alias SummonerWatchDog.Summoners.SummonerMatch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :matches, list_matches())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit match")
    |> assign(:match, SummonerMatches.get_summoner_match!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New match")
    |> assign(:match, %SummonerMatch{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Summoners matches")
    |> assign(:match, nil)
  end

  defp list_matches do
    SummonerMatches.list_summoner_matches()
  end
end
