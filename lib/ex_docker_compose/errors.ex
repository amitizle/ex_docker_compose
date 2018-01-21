defmodule ExDockerCompose.Subcommands.CommandNotFoundError do
  @moduledoc """
  An exception used when a docker-compose command is not defined / illegal
  """
  defexception [:message]
end
