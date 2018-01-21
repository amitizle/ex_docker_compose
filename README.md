# ExDockerCompose

`ExDockerCompose` is a simple library to for interacting with [`docker-compose`](https://docs.docker.com/compose/).
It's a wrapper for the `docker-compose` binary and running the actuall commands by using [Porcelain](https://github.com/alco/porcelain).

It works by spawning a `GenServer` that's using `Porcelain.spawn_shell/2` and handles the messages coming from the
process.

## Usage

TL;DR: `ExDockerCompose.<subcommand>(<compose_opts>, <subcommand_opts>)`, where:

  * `subcommand` is one of the available `docker-compose` subcommands.
  * `compose_opts` is a `List` of parameters to the `docker-compose` binary (not for the subcommand), type `docker-comose --help` to see those.
  * `subcommand_opts` is a `List` of parameters to the specific subcommand, for example; `docker-compose up -t 10`

Since the library simply takes those and translates the command, subcommand and the opts to a `docker-compose` binary execution,
usage is similar to the regular usage of `docker-compose`.

### Example

Consider the following `docker-compose` definition and assume that the yaml file is
located at `/tmp/docker-compose.yml`. The content of the file is:

```yaml
version: '3'
services:
  redis:
    image: "redis:alpine"
```

```elixir
$ iex -S mix

iex(1)> ExDockerCompose.up([{:f, "/tmp/docker-compose.yml"}], [])
:ok
iex(2)> Creating network "tmp_default" with the default driver
Creating tmp_redis_1 ... done

Attaching to tmp_redis_1
redis_1  | 1:C 21 Jan 17:16:28.737 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
redis_1  | 1:C 21 Jan 17:16:28.737 # Redis version=4.0.6, bits=64, commit=00000000, modified=0, pid=1, just started
redis_1  | 1:C 21 Jan 17:16:28.737 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis_1  | 1:M 21 Jan 17:16:28.739 * Running mode=standalone, port=6379.
redis_1  | 1:M 21 Jan 17:16:28.739 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
redis_1  | 1:M 21 Jan 17:16:28.739 # Server initialized
redis_1  | 1:M 21 Jan 17:16:28.739 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
redis_1  | 1:M 21 Jan 17:16:28.739 * Ready to accept connections

nil
iex(3)> ExDockerCompose.stop([{:f, "/tmp/docker-compose.yml"}], [])
:ok
iex(4)> Stopping tmp_redis_1 ...
redis_1  | 1:signal-handler (1516554998) Received SIGTERM scheduling shutdown...
redis_1  | 1:M 21 Jan 17:16:38.442 # User requested shutdown...
redis_1  | 1:M 21 Jan 17:16:38.442 * Saving the final RDB snapshot before exiting.
redis_1  | 1:M 21 Jan 17:16:38.449 * DB saved on disk
Stopping tmp_redis_1 ... done

tmp_redis_1 exited with code 0

pid #PID<0.168.0> exited with exit code 0 (command /usr/local/bin/docker-compose -f /tmp/docker-compose.yml stop)
pid #PID<0.163.0> exited with exit code 0 (command /usr/local/bin/docker-compose -f /tmp/docker-compose.yml up)

nil
```

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
