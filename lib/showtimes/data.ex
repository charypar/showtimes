defmodule Showtimes.Data do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {Showtimes.Data.Store.Server, name: Showtimes.Data.Store},
      {Task.Supervisor, name: Showtimes.Data.TaskSupervisor},
      {
        Showtimes.Data.FetchScheduler,
        name: Showtimes.Data.FetchScheduler,
        task: {Showtimes.Data.Fetch, :fetch, [[timeout: 5_000]]},
        subscribe: {Showtimes.Data.Store, :put}
      }
    ]

    Supervisor.init(children, strategy: :rest_for_one, name: Showtimes.Data.Supervisor)
  end
end
