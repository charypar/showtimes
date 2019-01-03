defmodule Showtimes.Data.Fetch do
  use Task
  require Logger

  def fetch(args) do
    timeout = Keyword.get(args, :timeout, 1000)

    Process.sleep(timeout)
    films = mock_films()

    films
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
