defmodule TeslaMiddlewareTapperTest do
  use ExUnit.Case
  doctest TeslaMiddlewareTapper

  test "greets the world" do
    assert TeslaMiddlewareTapper.hello() == :world
  end
end
