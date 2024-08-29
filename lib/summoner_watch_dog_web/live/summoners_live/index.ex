defmodule SummonerWatchDogWeb.SummonerLive.Index do
  use SummonerWatchDogWeb, :live_view

  alias SummonerWatchDog.Summoners
  alias SummonerWatchDog.Summoners.Summoner

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :summoners, list_summoners())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit summoner")
    |> assign(:summoner, Summoners.get_summoner!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New summoner")
    |> assign(:summoner, %Summoner{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Summoners")
    |> assign(:summoner, nil)
  end

  defp list_summoners do
    Summoners.list_summoners()
  end
end
