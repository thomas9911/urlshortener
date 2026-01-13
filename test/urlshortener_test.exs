defmodule UrlshortenerTest do
  use ExUnit.Case
  doctest Urlshortener

  test "greets the world" do
    assert Urlshortener.hello() == :world
  end
end
