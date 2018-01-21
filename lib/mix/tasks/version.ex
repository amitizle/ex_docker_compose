defmodule Mix.Tasks.Version do
  use Mix.Task

  @shortdoc "Bump VERSION file (major.minor.patch)"

  @moduledoc """
  This task is written to easily bump the version file of the boker_tov_nissim application.
  The versioning is following the semantic versioning methodology.
  With the task one can bump the major, minor or patch version of the application by specifying
  it as an argument;

  $ mix version bump patch

  $ mix version bump minor

  $ mix version bump major
  """

  @version_file "VERSION"

  def run(["bump", type]) do
    Mix.shell.info("Bumping #{type}")
    current_version = current_version()
    do_bump(type, current_version)
  end

  defp do_bump("major", [major, _minor, _patch]) do
    new_version = Enum.join([major + 1, 0, 0], ".")
    Mix.shell.info("New version: #{new_version}")
    write_new_version(new_version)
  end

  defp do_bump("minor", [major, minor, _patch]) do
    new_version = Enum.join([major, minor + 1, 0], ".")
    Mix.shell.info("New version: #{new_version}")
    write_new_version(new_version)
  end

  defp do_bump("patch", [major, minor, patch]) do
    new_version = Enum.join([major, minor, patch + 1], ".")
    Mix.shell.info("New version: #{new_version}")
    write_new_version(new_version)
  end

  defp do_bump(unsupported_type, _current_version) do
    Mix.shell.error("Don't know how to bump #{unsupported_type}")
  end

  defp current_version do
    case File.read(@version_file) do
      {:ok, content} ->
        Enum.map(String.split(String.trim_trailing(content, "\n"), "."),
                                                   fn(int) ->
                                                     String.to_integer(int)
                                                   end)
      {:error, reason} ->
        Mix.shell.error("Cannot read version file #{@version_file}; #{reason}")
    end
  end

  defp write_new_version(new_version) do
    case File.write(@version_file, new_version) do
      :ok ->
        Mix.shell.info("Wrote new version #{new_version} to #{@version_file}")
      {:error, reason} ->
        Mix.shell.error("Failed writing new version #{new_version} to #{@version_file}, reason: #{reason}")
    end
  end

end
