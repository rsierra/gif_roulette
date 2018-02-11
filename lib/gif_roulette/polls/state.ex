defmodule GifRoulette.Polls.State do
  defstruct poll: %{}, time: 20

  def new(poll, time) do
    %__MODULE__{
      poll: poll,
      time: time
    }
  end
end