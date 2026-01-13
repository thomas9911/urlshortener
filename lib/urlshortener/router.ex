defmodule Urlshortener.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/:id" do
    case :ets.lookup_element(:url_shortener, id, 2, :not_found) do
      :not_found ->
        conn
        |> send_resp(404, "Not found")
      url ->
        conn
        |> put_resp_header("Location", url)
        |> send_resp(301, "Moved to #{url}")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
