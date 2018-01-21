defmodule ExDockerCompose.Subcommands do
  @moduledoc """
  A module that is the source of truth for the supported subcommands on `docker-compose`.
  as well as how they should be used.
  """

  @supported_subcommands [
    :build, :bundle, :config, :create,
    :down, :events, :exec, :help,
    :images, :kill, :logs, :pause,
    :port, :ps, :pull, :push,
    :restart, :rm, :run, :scale,
    :start, :stop, :top, :unpause, :up
  ]

  @doc """
  Get a list of all supported subcommands

  ## Examples

      iex> ExDockerCompose.Subcommands.get_supported_subcommands()
      [:build, :bundle, :config, :create,
      :down, :events, :exec, :help,
      :images, :kill, :logs, :pause,
      :port, :ps, :pull, :push,
      :restart, :rm, :run, :scale,
      :start, :stop, :top, :unpause, :up]
  """
  @spec get_supported_subcommands() :: subcommands :: List.t
  def get_supported_subcommands do
    @supported_subcommands
  end

  @doc """
  Build the full command that should be running, this function will parse
  the arguments and will build a command line commnad out of the subcommand and
  the arguments and their parameters

  ## Parameters

    - `compose_bin` - The full path to the `docker-compose` binary
    - `subcommand` - The subcommand that `docker-compose` will run.
    - `compose_opts` - A list of parameters and their optional arguments used for `docker-compose`
      cli - meaning not for the subcommand. For example: `:f` (`-f`) or `:no_ansi` (`--no-ansi`)
      Every item on the `List` is either an atom (`:d`, `:timeout`) or a tuple where the first item is
      the an `Atom` that is the paramter and the rest are arguments to the paramter (space separated).
      For example: `[{:p, "project-name"}, {:f, "docker-compose.yml"}, :skip_hostname_check]`
    - `opts` - A list of parameters and their optional arguments **for the subcommand**.
      The structure is similar to the one described in `compose_opts`, but those will come
      **after** the subcommand.
      For example: `[:d, {:t, 10}]`.
  ## TODO
  Both `opts` and `compose_opts` currently only support **one** argument for a subcommand, i.e.
  `[:d, {:t, 10},...]` is ok while `[:d, {:t, 10, 20}]` is not.
  """
  @spec build_command(compose_bin :: String.t, subcommand :: Atom.t, compose_opts :: List.t, opts :: List.t)
        :: {:ok, full_command :: String.t} | :no_such_command
  def build_command(compose_bin, subcommand, compose_opts, opts) do
    case Enum.member?(@supported_subcommands, subcommand) do
      true -> {:ok, tidy_command([compose_bin, build_cli_params(compose_opts), subcommand, build_cli_params(opts)])}
      false -> :no_such_command
    end
  end

  @doc false
  @spec tidy_command(items :: List.t) :: full_command :: String.t
  defp tidy_command([compose_exec | items]) do
    Enum.reduce(items, compose_exec, fn
      (nil, full_command) -> full_command
      (item, full_command) -> "#{full_command} #{item}"
    end)
  end

  @doc false
  defp build_cli_params([]) do
    nil
  end
  defp build_cli_params(opts) do
    cli_param = fn(param) ->
      string_param = String.replace(Atom.to_string(param), "_", "-")
      case String.length(string_param) do
        1 -> "-#{string_param}"
        _ -> "--#{string_param}"
      end
    end
    opts |>
    Enum.map_join(" ", fn
      {param, argument} -> "#{cli_param.(param)} #{argument}"
      param -> cli_param.(param)
    end)
  end
end
