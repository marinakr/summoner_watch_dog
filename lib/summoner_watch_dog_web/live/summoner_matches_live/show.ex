defmodule SummonerWatchDogWeb.SummonerMatchLive.Show do
  use SummonerWatchDogWeb, :live_view

  alias SummonerWatchDog.SummonerMatches

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:match, SummonerMatches.get_summoner_match!(id))}
  end

  defp page_title(:show), do: "Show Summoner match"
  defp page_title(:edit), do: "Edit Summoner match"
end
