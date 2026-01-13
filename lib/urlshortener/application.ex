defmodule Urlshortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :url_shortener = :ets.new(:url_shortener, [:ordered_set, :public, :named_table, {:read_concurrency, true}])

    :ets.insert(:url_shortener, {"oke", "https://google.com"})

    children = [
      {Bandit, plug: Urlshortener.Router}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Urlshortener.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
