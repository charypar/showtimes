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
    Logger.info("Fetching currently playing films...")
    film_names = current_films()

    Logger.info("Done. Finding film ids...")

    raw_films =
      film_names
      |> Enum.map(&Task.async(fn -> find_film(&1) end))
      |> Enum.flat_map(&Task.await(&1, 10_000))
      |> Enum.group_by(fn f -> f["film_id"] end)
      |> Enum.map(fn {_k, [first | _t]} -> first end)

    Logger.info("Finished.")

    raw_films
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

  def http_fetch(uri) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!(uri, [], timeout: 15_000, recv_timeout: 15_000)

    body
  end

  defp mock_films() do
    [
      %{
        title: "Avengers: Age of Ultron",
        year: 2015,
        showtimes: [
          %{
            cinema: %{name: "Curzon Soho"},
            times: ["10:50", "14:00", "20:20"]
          },
          %{
            cinema: %{name: "Vue Islington"},
            times: ["10:50", "14:00", "20:20"]
          }
        ]
      }
    ]
  end
end
