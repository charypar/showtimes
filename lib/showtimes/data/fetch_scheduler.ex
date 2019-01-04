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
    {:ok, {_mod, _fun, _args} = task} = Keyword.fetch(opts, :task)
    {:ok, {_pid, _message} = sub} = Keyword.fetch(opts, :subscribe)
    interval = Keyword.get(opts, :interval, 4 * 60 * 60 * 1000)

    timer = schedule(interval)
    trigger_fetch(task)

    {:ok, {timer, interval, task, sub}}
  end

  def handle_info(:trigger, {previous_timer, interval, task, sub}) do
    timer = schedule(previous_timer, interval)
    trigger_fetch(task)

    {:noreply, {timer, interval, task, sub}}
  end

  def handle_info({_ref, data}, {_tm, _i, _ts, {pid, msg}} = state) do
    # Notify subscriber
    send(pid, {msg, data})

    {:noreply, state}
  end

  # ignore Task termination
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp schedule(timer, interval) do
    Process.cancel_timer(timer)
    schedule(interval)
  end

  defp schedule(interval) do
    Process.send_after(self(), :trigger, interval)
  end

  defp trigger_fetch({mod, fun, args}) do
    Task.Supervisor.async_nolink(Showtimes.Data.TaskSupervisor, mod, fun, args)
  end
end
