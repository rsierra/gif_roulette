defmodule GifRoulette.Polls.Result do
  defstruct winner: ""

  def new(winner) do
    %__MODULE__{
      winner: winner
    }
  end
end