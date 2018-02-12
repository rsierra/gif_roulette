defmodule GifRoulette.Polls.Store do
  @name __MODULE__
  @options ~w(cats sad funny wtf cute meh cry dance fail win)

  def start_link do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def init() do
    Agent.update(@name, fn _state ->
      @options
      |> Enum.take_random(3)
      |> Enum.reduce(%{}, fn key, state ->
        Map.put(state, key, 0)
      end)
    end)
  end

  def state() do
    Agent.get(@name, fn state ->
      state
    end)
  end

  def vote(key) do
    Agent.update(@name, fn state ->
      case Map.get(state, key) do
        nil -> state
        votes -> Map.put(state, key, votes + 1)
      end
    end)
  end

  def winner() do
    Agent.get(@name, fn state ->
      {winners, _votes} = Enum.reduce(state, {[], 0},&check_winner/2)
      Enum.random(winners)
    end)
  end

  defp check_winner({key, votes}, {[] = winners, greatest}) when votes == greatest do
    {[key | winners], greatest}
  end

  defp check_winner({key, votes}, {_winners, greatest}) when votes > greatest do
    {[key], votes}
  end

  defp check_winner(_element, result), do: result
end
