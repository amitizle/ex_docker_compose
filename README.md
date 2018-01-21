# ExDockerCompose

`ExDockerCompose` is a simple library to for interacting with [`docker-compose`](https://docs.docker.com/compose/).
It's a wrapper for the `docker-compose` binary and running the actuall commands by using [Porcelain](https://github.com/alco/porcelain).

It works by spawning a `GenServer` that's using `Porcelain.spawn_shell/2` and handles the messages coming from the
process.

## Testing locally

```bash
$ mix do deps.get, deps.compile
$ mix test
```

Tests are incomplete at the moment.

## Configuration

`docker-compose` executable path is configurable by either using [Application](https://hexdocs.pm/elixir/Application.html#get_env/3)
config, or by using an environment varibale.
Note that the `Application` config has the precedence.

```elixir
config :ex_docker_compose, :bin_file, "/path/to/docker-compose"
```

As an environment variable, `ExDockerCompose` will look for `DOCKER_COMPOSE_BIN`.
If non of them are found, `ExDockerCompose` will get the `docker-compose` executable by using
[`System.find_executable("docker-compose")`](https://hexdocs.pm/elixir/System.html#find_executable/1)

### Config Porcelain

`Porcelain` can be configured to use the [goon driver](https://github.com/alco/porcelain#configuring-the-goon-driver).
`ExDockerCompose` configured to use `:goon_warn_if_missing = true` to deprecate the warnings, however, one can configure
`Porcelain` to use the `goon` driver locally by adding the same configuration that's described on `Porcelain` docs:

```elixir
config :porcelain, :goon_driver_path, <path>
```
