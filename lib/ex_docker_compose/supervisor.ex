defmodule ExDockerCompose.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      supervisor(ExDockerCompose.RunServer, [])
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
