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
        {} -> {500, "No data."}
        _ -> {200, "OK"}
      end

    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(status, text)
  end

  def page(conn, _opts) do
    json =
      Showtimes.Data.Store.get(Showtimes.Data.Store)
      |> present_results()
      |> Poison.encode!()

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(200, json)
  end

  defp present_results({}) do
    []
  end

  defp present_results({venues, films, showings}) do
    Enum.map(films, fn {film_id, film} ->
      film_venues =
        venues
        |> Enum.map(fn {venue_id, v} ->
          ss = showings[{film_id, venue_id}]
          venue = Map.take(v, ["name", "distance", "lat", "lon", "website"])

          if ss do
            Map.put(venue, "times", Enum.map(ss, &Map.take(&1, ["showtime", "ticketing_link"])))
          else
            nil
          end
        end)
        |> Enum.filter(&(&1 && String.to_float(&1["distance"]) <= 10))

      Map.put(film, "venues", film_venues)
    end)
  end
end
