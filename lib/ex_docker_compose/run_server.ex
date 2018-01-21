defmodule ExDockerCompose.RunServer do
  @moduledoc """
  The worker module, this is a GenServer that handles running of docker-compose
  commands.
  The module tracks all commands that were requested to run.
  """
  use GenServer
  alias Porcelain.Process, as: Proc
  alias ExDockerCompose.Subcommands.CommandNotFoundError

  ## GenServer state
  defstruct [
    compose_bin: nil,
    in_flight_procs: %{},
    outputs: %{out: [], err: []}
  ]
  @type t ::%__MODULE__{
    compose_bin: String.t,
    in_flight_procs: Map.t,
    outputs: Map.t
  }

  @server :runner

  ## API

  @doc ~S"""
  Runs the given subcommand and opts.
  See `ExDockerCompose` functions documentation for the expected
  syntax of `opts`.

  ## Parameters

    - `subcommand` - The `docker-compose` subcommand to run
    - `compose_opts` - A list with options for the docker-compose command.
      Refer to `ExDockerCompose.Subcommands.build_command/4` for the expected syntax
    - `opts` - A list with options for the subcommand.
      Refer to `ExDockerCompose.Subcommands.build_command/4` for the expected syntax

  ## Examples

      iex> ExDockerCompose.RunServer.run(:up, [{:f "compose.yaml"}], [:d, {:timeout, 10}])
      :ok

      iex> ExDockerCompose.RunServer.run(:up, [], [])
      :ok

      iex> ExDockerCompose.RunServer.run(:no_such_command, [], [])
      {:error, "Command no_such_command not found"}

  """
  @spec run(subcommand :: Atom.t, compose_opts :: List.t, opts :: List.t) :: :ok | {:error, reason :: String.t}
  def run(subcommand, compose_opts, opts) do
    case GenServer.call(@server, {:get_command, subcommand, compose_opts, opts}) do
      {:ok, command} -> GenServer.cast(@server, {:do_command, command})
      :no_such_command -> {:error, "Command #{subcommand} not found"}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc ~S"""
  Same as `ExDockerCompose.RunServer.run/2`, only that raises an exception if there's an error.

  ## Examples

      iex> ExDockerCompose.RunServer.run!(:up, [{:f, "compose.yml"}], [:d, {:timeout, 10}])
      :ok

      iex> ExDockerCompose.RunServer.run!(:no_such_command, [], [:d, {:timeout, 10}])

  """
  @spec run!(subcommand :: Atom.t, compose_opts :: List.t, opts :: List.t) :: :ok | no_return
  def run!(subcommand, compose_opts, opts) do
    case run(subcommand, compose_opts, opts) do
      :ok -> :ok
      :no_such_command -> raise CommandNotFoundError, message: "Command #{subcommand} not found"
      {:error, reason} -> raise reason
    end
  end

  ##  Callbacks

  @doc """
  Initialize the server
  ## Parameters
    - `args` - a Keyword list with the following keys:
      - `compose_bin` - A full path to the `docker-compose` binary file.
        This will be used in order to run the commands.
  """
  def init(args) do
    state = struct(__MODULE__, args)
    {:ok, state}
  end

  @doc false
  def start_link do
    args = [
      compose_bin: get_compose_bin(),
      outputs: get_outputs()
    ]
    GenServer.start_link(__MODULE__, args, [name: @server])
  end

  @doc false
  def handle_call({:get_command, subcommand, compose_opts, opts}, _from, state) do
    %__MODULE__{compose_bin: compose_bin} = state
    reply = ExDockerCompose.Subcommands.build_command(compose_bin, subcommand, compose_opts, opts)
    {:reply, reply, state}
  end

  @doc false
  def handle_cast({:do_command, command}, state) do
    proc = run_command("#{command} 2>&1") # TODO temporarily 2>&1, see the comment on the run_command/1 function
    in_flight_procs = state.in_flight_procs
    new_in_flight_procs = Map.put(in_flight_procs, proc, command)
    new_state = %__MODULE__{state | in_flight_procs: new_in_flight_procs}
    {:noreply, new_state}
  end

  @doc false
  def handle_info({_pid, :data, :out, data}, state) do
    write_out(data, state)
    {:noreply, state}
  end

  @doc false
  def handle_info({_pid, :data, :err, data}, state) do
    IO.puts "ERROR"
    write_out(data, state)
    {:noreply, state}
  end

  @doc false
  def handle_info({pid, :result, %Porcelain.Result{status: status}}, state) do
    in_flight_procs = state.in_flight_procs
    pid_command = in_flight_procs[pid]
    write_out("pid #{inspect pid} exited with exit code #{status} (command #{pid_command})", state)
    new_in_flight_procs = Map.delete(in_flight_procs, pid)
    new_state = %__MODULE__{state | in_flight_procs: new_in_flight_procs}
    {:noreply, new_state}
  end

  defp run_command(command) do
    # TODO track https://github.com/alco/porcelain/issues/47
    # Currently I can't get stderr to be handled :/
    %Proc{pid: pid, out: {:send, _out_pid}, err: {:send, _err_pid}} =
      Porcelain.spawn_shell(command, out: {:send, self()}, err: {:send, self()})
    pid
  end

  # Get the `docker-compose` binary path
  # Looks for config item `ex_docker_compose.bin_file`
  # Otherwise looks for the `DOCKER_COMPOSE_BIN` environment variable.
  # If non of them are configured, get the executable by `System.find_executable`.
  defp get_compose_bin do
    system_bin_file = System.get_env("DOCKER_COMPOSE_BIN")
    bin_file = Application.get_env(:ex_docker_compose, :bin_file, system_bin_file)
    case bin_file do
      nil -> System.find_executable("docker-compose")
      _ -> bin_file
    end
  end

  # This is temporary, maybe.
  # In the future we might want to support configurable logger
  # or input drivers to write the results to.
  defp get_outputs do
    %{
      out: [fn(message) -> IO.puts(message) end],
      err: [fn(message) -> IO.puts(:stderr, message) end]
    }
  end

  defp write_out(message, state) do
    %__MODULE__{outputs: outputs} = state
    do_write_out_err(message, outputs[:out])
  end

  # defp write_err(message, state) do
  #   %__MODULE__{outputs: outputs} = state
  #   do_write_out_err(message, outputs[:err])
  # end

  defp do_write_out_err(message, outputs) do
    Enum.each(outputs, fn(output) ->
      output.(String.trim(message))
    end)
  end
end
