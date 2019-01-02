defmodule SimonaTest do
  use ExUnit.Case
  doctest Simona

  test "greets the world" do
    assert Simona.hello() == :world
  end
end
