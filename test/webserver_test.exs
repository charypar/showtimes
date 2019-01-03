defmodule Showtimes.WebServerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "returns hello" do
    conn = conn(:get, "/")

    conn = Showtimes.WebServer.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
  end
end
