defmodule Showtimes.Data.FetchSchedulerTest do
  use ExUnit.Case, async: true
  alias Showtimes.Data.FetchScheduler, as: Scheduler

  defmodule MockTask do
    def run do
      Process.sleep(10)
      :done
    end
  end

  setup context do
    start_supervised!({
      Scheduler,
      name: context.test, interval: 2, task: {MockTask, :run, []}, subscribe: {self(), :return}
    })

    %{scheduler: context.test}
  end

  test "does not start without a subscriber" do
    assert {:error, _reason} = Scheduler.start_link(task: {MockTask, :run, []})
  end

  test "does not start without a task" do
    assert {:error, _reason} = Scheduler.start_link(subscribe: {self(), :return})
  end

  test "runs the task and notifies subscriber" do
    assert_receive({:return, :done}, 13)
  end

  test "runs the task and notifies subscriber multiple times" do
    assert_receive({:return, :done}, 13)
    assert_receive({:return, :done}, 5)
    assert_receive({:return, :done}, 5)
  end
end
