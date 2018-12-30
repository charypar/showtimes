defmodule Showtimes.WebServer do
  alias Plug.Conn
  use Plug.Builder

  plug(:greet)

  def init(opts) do
    opts
  end

  def greet(conn, _opts) do
    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(200, "Hello!")
  end
end
