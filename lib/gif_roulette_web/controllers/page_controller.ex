defmodule GifRouletteWeb.PageController do
  use GifRouletteWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
