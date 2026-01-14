defmodule Urlshortener.Router do
  use Plug.Router

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "shorten/:id" do
    case get_url(id) do
      nil ->
        conn
        |> send_json(404, %{error: "not found"})

      url ->
        conn
        |> send_json(200, %{shortCode: id, url: url})
    end
  end

  post "shorten" do
    case conn.body_params do
      %{"url" => url} ->
        new_shortcode = gen_code()
        if insert_url(new_shortcode, url) do
          conn
          |> send_json(200, get_record(new_shortcode))
        else
          conn
          |> send_json(500, %{error: "unable to insert data"})
        end
      _ ->
        conn
        |> send_json(400, %{error: "missing 'url' in request body"})
    end
  end

  get "/:id" do
    case get_url(id) do
      nil ->
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

  defp gen_code do
    code = :rand.bytes(8) |> Base.url_encode64(padding: false)
    case get_url(code) do
      nil -> code
      _ -> gen_code()
    end
  end

  defp send_json(conn, status_code, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(map))
  end

  defp get_url(id) do
    :ets.lookup_element(:url_shortener, id, 2, nil)
  end

  defp get_record(id) do
    case :ets.lookup(:url_shortener, id) |> List.first() do
      nil -> nil
      {shortcode, url, created_at, updated_at} -> %{
          shortCode: shortcode, url: url, createdAt: created_at, updatedAt: updated_at
        }
    end
  end

  defp insert_url(shortcode, url) do
    data = {shortcode, url, DateTime.utc_now |> DateTime.to_iso8601, DateTime.utc_now |> DateTime.to_iso8601}
    :ets.insert(:url_shortener, data)
  end
end
