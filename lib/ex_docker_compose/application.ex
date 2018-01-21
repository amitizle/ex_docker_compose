defmodule ExDockerCompose.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(ExDockerCompose.Supervisor, [])
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
