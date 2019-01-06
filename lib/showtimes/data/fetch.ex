defmodule Showtimes.Data.Fetch do
  use Task
  require Logger

  @moduledoc """
  There are several options of how to get the data.

  # FindAnyFilm

  1. Find films in London
  > https://www.findanyfilm.com/find-cinema-tickets?townpostcode=WC2N5DX

  2.
  Find film ids by first letter (parallel)
  > https://www.findanyfilm.com/search/live-film?term=B

  3. Find screenings today (parallel)
  > https://www.findanyfilm.com/api/screenings/by_film_id/film_id/162633/date_from/2019-01-03/townpostcode/WC2N5DX
  When we do more days:
  > https://www.findanyfilm.com/api/screenings/by_film_id/film_id/162633/date_from/2019-01-03/date_to/2019-01-06/townpostcode/WC2N5DX

  # London Net...?

  1. Follow all links in the list
  > https://www.londonnet.co.uk/cinema/

  2. Parse pages
  > e.g https://www.londonnet.co.uk/cinema/vueislington.html
  """

  def fetch(_args) do
    today = Date.utc_today() |> Date.to_iso8601()

    Logger.info("Fetching currently playing films...")

    film_names = current_films()

    Logger.info("Done. Finding film ids...")

    films =
      film_names
      |> Enum.map(&Task.async(fn -> find_film(&1) end))
      |> Enum.flat_map(&Task.await(&1, 30_000))
      |> Enum.uniq_by(fn f -> f["film_id"] end)

    Logger.info("Done. Finding all showings...")

    raw_showings =
      films
      |> Enum.map(&Task.async(fn -> find_showings(&1["film_id"], today) end))
      |> Enum.flat_map(&Task.await(&1, 30_000))

    Logger.info("Aggregating data...")

    [venues, films, showings] =
      raw_showings
      |> Enum.reduce(
        [%{}, %{}, %{}],
        fn venue, [venues, films, showings] ->
          v = %{venue | "films" => nil}

          venue_id = v["venue_id"]
          film_id = hd(Map.keys(venue["films"]))

          f = venue["films"][film_id]["film_data"]

          s =
            venue["films"][film_id]["showings"]
            |> Enum.map(&Map.merge(&1, %{"film_id" => film_id, "venue_id" => venue_id}))

          [
            if(v, do: Map.put(venues, venue_id, v), else: venues),
            if(f, do: Map.put(films, film_id, f), else: films),
            Map.put(showings, {film_id, venue_id}, s)
          ]
        end
      )

    result =
      films
      |> Enum.map(fn {film_id, film} ->
        film_venues =
          venues
          |> Enum.map(fn {venue_id, venue} ->
            ss = showings[{film_id, venue_id}]

            unless ss do
              nil
            else
              Map.put(
                Map.take(venue, ["name", "distance", "lat", "lon", "website"]),
                "times",
                Enum.map(ss, fn s -> Map.take(s, ["showtime", "ticketing_link"]) end)
              )
            end
          end)
          |> Enum.filter(& &1)

        Map.put(film, "venues", film_venues)
      end)

    Logger.info("Done.")

    result
  end

  defp current_films() do
    http_fetch("https://www.findanyfilm.com/find-cinema-tickets?townpostcode=WC2N5DX")
    |> Floki.find("li.filmTitle h1")
    |> Enum.map(&(&1 |> Floki.text() |> strip_year()))
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp strip_year(title) do
    title
    |> String.trim()
    |> String.split(" ")
    |> Enum.slice(0..-2)
    |> Enum.join(" ")
  end

  defp find_film(title) do
    http_fetch("https://www.findanyfilm.com/search/live-film?term=#{URI.encode(title)}")
    |> Poison.decode!()
  end

  defp find_showings(film_id, date) do
    uri =
      "https://www.findanyfilm.com/api/screenings/by_film_id/film_id/#{film_id}/date_from/#{date}/townpostcode/WC2N5DX"

    showings =
      http_fetch(uri)
      |> Poison.decode!()

    # make sure showings are list (even if empty)
    case showings do
      [_h | _t] = list -> list
      _ -> []
    end
  end

  def http_fetch(uri) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!(uri, [], timeout: 15_000, recv_timeout: 15_000)

    body
  end
end
