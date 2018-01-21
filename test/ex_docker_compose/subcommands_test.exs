defmodule ExDockerCompose.SubcommandsTest do
  use ExUnit.Case
  doctest ExDockerCompose.Subcommands

  @compose_bin "/bin/dc"

  test "build command without opts should just return the subcommand" do
    assert {:ok, "#{@compose_bin} up"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [], [])
  end

  test "build command with one letter opts and no args" do
    assert {:ok, "#{@compose_bin} up -d"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [], [:d])
  end

  test "build command with one letter opts and multiple args" do
    assert {:ok, "#{@compose_bin} up -d -t 10"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [], [:d, {:t, 10}])
  end

  test "build command with many letters opts and no args" do
    assert {:ok, "#{@compose_bin} up --dummy"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [], [:dummy])
  end

  test "build command with many letters opts" do
    assert {:ok, "#{@compose_bin} up --dummy --timeout 10"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [], [:dummy, {:timeout, 10}])
  end

  test "build command with docker-compose opts only" do
    assert {:ok, "#{@compose_bin} -f compose.yml up"} = ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [{:f, "compose.yml"}], [])
  end

  test "build command with docker-compose and subcommand opts" do
    assert {:ok, "#{@compose_bin} -f compose.yml up -d -t 10"} =
      ExDockerCompose.Subcommands.build_command(@compose_bin, :up, [{:f, "compose.yml"}], [:d, {:t, 10}])
  end

end
