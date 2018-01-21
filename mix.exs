defmodule ExDockerCompose.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_docker_compose,
      version: String.trim_trailing(File.read!("VERSION"), "\n"),
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "ExDockerCompose",
      source_url: "https://github.com/amitizle/ex_docker_compose",
      homepage_url: "https://github.com/amitizle/ex_docker_compose", # TODO generate docs
      docs: [
        main: "ExDockerCompose",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExDockerCompose.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:porcelain, "~> 2.0"},
      {:ex_doc, "~> 0.18.1", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A simple wrapper library on top of docker-compose binary,
    allows control of docker-compose command via Elixir code.
    """
  end

  defp package do
    [
      name: "ex_docker_compose",
      files: ["lib", "mix.exs", "README.md", "config", "LICENSE", "VERSION"],
      maintainers: ["Amit Goldberg"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/amitizle/ex_docker_compose"}
    ]
  end
end
