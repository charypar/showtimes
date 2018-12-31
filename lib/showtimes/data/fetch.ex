defmodule Showtimes.Data.Fetch do
  require Logger

  def fetch(args) do
    timeout = Keyword.get(args, :timeout, 1000)

    Logger.info("#{inspect(self())}: Fetching now, it'll take #{timeout} ms...")
    Process.sleep(timeout)
    Logger.info("#{inspect(self())}: done.")

    :ok
  end
end
