defmodule Showtimes.Data.StoreTest do
  use ExUnit.Case, async: true
  alias Showtimes.Data.Store

  setup context do
    films = [
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

    store = start_supervised!({Store.Server, name: context.test})
    Store.put(store, films)

    %{films: films, store: context.test}
  end

  test "doesn't start without a name" do
    catch_error(Store.start_link([]))
  end

  test "finds all films", %{films: films, store: store} do
    assert Store.get(store) == films
  end

  test "updates the films", %{films: films, store: store} do
    new_films = [
      %{
        title: "Avengers: Age of Ultron",
        year: 2015,
        showtimes: [
          %{cinema: %{name: "Curzon Soho"}, times: ["10:50", "14:00", "20:20"]}
        ]
      }
    ]

    assert Store.get(store) == films

    :ok = Store.put(store, new_films)

    assert Store.get(store) == new_films
  end
end
