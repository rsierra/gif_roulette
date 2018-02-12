defmodule GifRoulette.Polls.Manager do
  @name __MODULE__
  @duration 16

  use GenServer

  alias GifRoulette.Polls.Store
  alias GifRoulette.Polls.State
  alias GifRoulette.Polls.Result
  alias GifRouletteWeb.Endpoint

  # CLIENT

  def start_link() do
    state = %{
      start_at: :os.system_time(:second)
    }
    GenServer.start_link(@name, state, name: @name)
  end

  def state() do
    GenServer.call(@name, :state)
  end

  defdelegate vote(key), to: Store

  # SERVER

  def init(state) do
    Store.start_link()
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    result = Store.winner() |> Result.new()
    Endpoint.broadcast("roulette:lobby", "result", result)
    schedule_work() # Reschedule once more
    # Reset the pool time and broadcast poll state to clients
    poll_state = Store.state() |> State.new(@duration)
    Endpoint.broadcast("roulette:lobby", "sync", poll_state)
    # Update the start_at state for the new iteration
    {:noreply, %{state | start_at: :os.system_time(:second)}}
  end

  defp schedule_work() do
    Store.init()
    Process.send_after(self(), :work, @duration * 1000)
  end

  def handle_call(:state, _from, state) do
    poll_state = Store.state() |> State.new(time_left(state))
    {:reply, poll_state, state}
  end

  defp time_left(%{start_at: start_at}) do
    @duration - (:os.system_time(:second) - start_at)
  end
end