defmodule SummonerWatchDogWeb.SummonerLive.FormComponent do
  use SummonerWatchDogWeb, :live_component

  alias SummonerWatchDog.Summoners

  @impl true
  def update(%{summoner: summoner} = assigns, socket) do
    changeset = Summoners.change_summoner(summoner)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"summoner" => summoner_params}, socket) do
    changeset =
      socket.assigns.summoner
      |> Summoners.change_summoner(summoner_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"summoner" => summoner_params}, socket) do
    save_summoner(socket, socket.assigns.action, summoner_params)
  end

  defp save_summoner(socket, :edit, summoner_params) do
    case Summoners.update_summoner(socket.assigns.summoner, summoner_params) do
      {:ok, _summoner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Summoners updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_summoner(socket, :new, summoner_params) do
    case Summoners.create_summoner(summoner_params) do
      {:ok, _summoner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Summoners created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
