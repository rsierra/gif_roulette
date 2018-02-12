defmodule GifRoulette.Polls.Result do
  defstruct winner: "", url: ""

  def new(winner) do
    %__MODULE__{
      winner: winner,
      url: gif(winner)
    }
  end

  def gif(winner) do
    with {:ok, %Giphy.Page{data: data}} <- Giphy.search(winner),
      %Giphy.GIF{images: images} <- Enum.random(data)
    do
      get_in(images,["original", "url"])
    else
      _ -> "https://0ducks.files.wordpress.com/2015/05/404.gif"
    end
  end
end