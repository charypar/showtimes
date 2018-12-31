defmodule Showtimes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Showtimes.Data,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Showtimes.WebServer,
        options: [port: 8080]
      )
    ]

    opts = [strategy: :one_for_one, name: Showtimes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
