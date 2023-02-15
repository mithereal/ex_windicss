defmodule Mix.Tasks.Windicss.Install do
  @moduledoc """
  Installs windicss under `_build`.

  ```bash
  $ mix windicss.install
  $ mix windicss.install --if-missing
  ```

  By default, it installs #{Windicss.latest_version()} but you
  can configure it in your config files, such as:

      config :windicss, :version, "#{Windicss.latest_version()}"

  ## Options

      * `--runtime-config` - load the runtime configuration
        before executing command

      * `--if-missing` - install only if the given version
        does not exist
  """

  @shortdoc "Installs windicss under _build"
  use Mix.Task

  @impl true
  def run(args) do
    valid_options = [runtime_config: :boolean, if_missing: :boolean]

    {opts, base_url} =
      case OptionParser.parse_head!(args, strict: valid_options) do
        {opts, []} ->
          {opts, Windicss.default_base_url()}

        {opts, [base_url]} ->
          {opts, base_url}

        {_, _} ->
          Mix.raise("""
          Invalid arguments to windicss.install, expected one of:

              mix windicss.install
              mix windicss.install 'https://github.com/windicss/windicss/releases/download/v$version/windicsscss-$target'
              mix windicss.install --runtime-config
              mix windicss.install --if-missing
          """)
      end

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    if opts[:if_missing] && latest_version?() do
      :ok
    else
      Windicss.install(base_url)
    end
  end

  defp latest_version?() do
    version = Windicss.configured_version()
    match?({:ok, ^version}, Windicss.bin_version())
  end
end
