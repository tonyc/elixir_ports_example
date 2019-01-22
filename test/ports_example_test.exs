defmodule PortsExampleTest do
  use ExUnit.Case
  doctest PortsExample

  test "greets the world" do
    assert PortsExample.hello() == :world
  end
end
