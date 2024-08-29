defmodule SummonerWatchDogWeb.SummonerMatchLive.FormComponent do
  use SummonerWatchDogWeb, :live_component

  alias SummonerWatchDog.SummonerMatches

  @impl true
  def update(%{match: match} = assigns, socket) do
    changeset = SummonerMatches.change_summoner_match(match)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"match" => match_params}, socket) do
    changeset =
      socket.assigns.match
      |> SummonerMatches.change_summoner_match(match_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"match" => match_params}, socket) do
    save_summoner_match(socket, socket.assigns.action, match_params)
  end

  defp save_summoner_match(socket, :edit, match_params) do
    case SummonerMatches.update_summoner_match(socket.assigns.match, match_params) do
      {:ok, _match} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_summoner_match(socket, :new, match_params) do
    case SummonerMatches.create_summoner_match(match_params) do
      {:ok, _summoner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
