defmodule Showtimes.Data.Store do
  def get(name) do
    [films: films] = :ets.lookup(name, :films)

    films
  end

  def put(name, films) do
    GenServer.call(name, {:put, films})
  end

  defmodule Server do
    use GenServer
    require Logger

    def start_link(opts) do
      {:ok, table_name} = Keyword.fetch(opts, :name)
      GenServer.start_link(__MODULE__, table_name, opts)
    end

    def init(name) do
      films_table = :ets.new(name, [:named_table, read_concurrency: true])

      {:ok, films_table}
    end

    def handle_call({:put, films}, _from, films_table) do
      :ets.insert(films_table, {:films, films})

      {:reply, :ok, films_table}
    end

    def handle_info({:put, films}, films_table) do
      :ets.insert(films_table, {:films, films})

      {:noreply, films_table}
    end
  end
end
