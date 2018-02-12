defmodule GifRouletteWeb.RouletteChannel do
  use GifRouletteWeb, :channel

  alias GifRouletteWeb.Presence
  alias GifRoulette.Polls.Manager

  def join("roulette:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, Manager.state(), socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user_id, %{
      online_at: :os.system_time(:milli_seconds)
    })

    broadcast(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("vote", %{"vote" => value}, socket) do
    Manager.vote(value)
    broadcast socket, "sync", Manager.state()
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
