defmodule Showtimes.Data.FetchScheduler do
  use GenServer
  require Logger

  def fetch(pid) do
    send(pid, :trigger)

    :ok
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    interval = Keyword.get(opts, :interval, 3000)

    timer = schedule(interval)
    trigger_fetch()

    {:ok, {timer, interval}}
  end

  def handle_info(:trigger, {previous_timer, interval}) do
    timer = schedule(previous_timer, interval)
    trigger_fetch()

    {:noreply, {timer, interval}}
  end

  defp schedule(timer, interval) do
    Process.cancel_timer(timer)
    schedule(interval)
  end

  defp schedule(interval) do
    Process.send_after(self(), :trigger, interval)
  end

  defp trigger_fetch do
    Task.Supervisor.start_child(Showtimes.Data.TaskSupervisor, Showtimes.Data.Fetch, :fetch, [
      [timeout: 5000]
    ])
  end
end
