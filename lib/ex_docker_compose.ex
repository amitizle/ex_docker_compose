defmodule ExDockerCompose do

  @moduledoc ~S"""
  ExDockerCompose is an Elixir library to call `docker-compose`
  commands from Elixir.
  This can be used for example to write Mix tasks
  """

  alias ExDockerCompose.RunServer
  alias ExDockerCompose.Subcommands
  require ExDockerCompose.RunServer
  require ExDockerCompose.Subcommands


  Subcommands.get_supported_subcommands |> Enum.each(fn(subcommand) ->
    @doc """
    `docker-compose` [compose_opts] subcommand #{subcommand} [subcommand_opts].

    See [docker-compose docs](https://docs.docker.com/compose/reference/#{subcommand}/)

    ## Parameters

      - `compose_opts` - options for `docker-compose` binary, see `ExDockerCompose.Subcommands.build_command/4`
        for expected formatting.
      - `opts` - options for the subcommand, see `ExDockerCompose.Subcommands.build_command/4`
        for expected formatting.

    """
    @spec unquote(subcommand)(compose_opts :: List.t, opts :: List.t) :: :ok | {:error, reason :: String.t}
    def unquote(subcommand)(compose_opts, opts) do
      RunServer.run(unquote(subcommand), compose_opts, opts)
    end

    @doc """
    Same as `ExDockerCompose.#{subcommand}/2`, only that raises
    exceptions instead or returning `:error` tuple.
    """
    @spec unquote(:"#{subcommand}!")(compose_opts :: List.t, opts :: List.t) :: :ok | no_return
    def unquote(:"#{subcommand}!")(compose_opts, opts) do
      RunServer.run!(unquote(subcommand), compose_opts, opts)
    end
  end)

end
