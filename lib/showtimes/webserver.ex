defmodule Showtimes.WebServer do
  alias Plug.Conn
  use Plug.Builder

  plug(:page)

  def init(opts) do
    opts
  end

  def page(%{path_info: ["_health"]} = conn, _opts) do
    {status, text} =
      case Showtimes.Data.Store.get(Showtimes.Data.Store) do
        [] -> {500, "No data."}
        _ -> {200, "OK"}
      end

    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(status, text)
  end

  def page(conn, _opts) do
    films = Showtimes.Data.Store.get(Showtimes.Data.Store)
    json = Poison.encode!(films)

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(200, json)
  end
end
