defmodule ExDockerComposeTest do
  use ExUnit.Case
  doctest ExDockerCompose

  test "all docker-compose functions are defined" do
    subcommands = ExDockerCompose.Subcommands.get_supported_subcommands
    ex_docker_compose_functions = ExDockerCompose.__info__(:functions)
    Enum.each(subcommands, fn(subcommand) ->
      assert Keyword.has_key?(ex_docker_compose_functions, subcommand)
    end)
  end

end
