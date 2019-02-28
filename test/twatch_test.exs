defmodule TwatchTest do
  use ExUnit.Case
  doctest Twatch

  test "greets the world" do
    assert Twatch.hello() == :world
  end
end
