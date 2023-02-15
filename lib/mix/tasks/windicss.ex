defmodule Mix.Tasks.Windicss do
  @moduledoc """
  Invokes windicss with the given args.

  Usage:

      $ mix windicss TASK_OPTIONS PROFILE WINDI_ARGS

  Example:

      $ mix windicss default --config=windicss.config.js \
        --input=css/app.css \
        --output=../priv/static/assets/app.css \
        --minify

  If windicss is not installed, it is automatically downloaded.
  Note the arguments given to this task will be appended
  to any configured arguments.

  ## Options

    * `--runtime-config` - load the runtime configuration
      before executing command

  Note flags to control this Mix task must be given before the
  profile:

      $ mix windicss --runtime-config default
  """

  @shortdoc "Invokes windicss with the profile and args"

  use Mix.Task

  @impl true
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Application.ensure_all_started(:windicss)
    end

    Mix.Task.reenable("windicss")
    install_and_run(remaining_args)
  end

  defp install_and_run([profile | args] = all) do
    case Windicss.install_and_run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix windicss #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  defp install_and_run([]) do
    Mix.raise("`mix windicss` expects the profile as argument")
  end
end
