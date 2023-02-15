# Windicss

[![CI](https://github.com/mithereal/windicss/actions/workflows/main.yml/badge.svg)](https://github.com/mithereal/windicss/actions/workflows/main.yml)

Mix tasks for installing and invoking [windicss](https://windicss.org)
## Installation

If you are going to build assets in production, then you add
`windicss` as dependency on all environments but only start it
in dev:

```elixir
def deps do
  [
    {:windicss, "~> 0.1.9", runtime: Mix.env() == :dev}
  ]
end
```

However, if your assets are precompiled during development,
then it only needs to be a dev dependency:

```elixir
def deps do
  [
    {:windicss, "~> 0.1.9", only: :dev}
  ]
end
```

Once installed, change your `config/config.exs` to pick your
windicss version of choice:

```elixir
config :windicss, version: "3.2.4"
```

Now you can install windicss by running:

```bash
$ mix windicss.install
```

And invoke windicss with:

```bash
$ mix windicss default
```

The executable is kept at `_build/windicss-TARGET`.
Where `TARGET` is your system target architecture.

## Profiles

The first argument to `windicss` is the execution profile.
You can define multiple execution profiles with the current
directory, the OS environment, and default arguments to the
`windicss` task:

```elixir
config :windicss,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=windicss.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]
```

When `mix windicss default` is invoked, the task arguments will be appended
to the ones configured above. Note profiles must be configured in your
`config/config.exs`, as `windicss` runs without starting your application
(and therefore it won't pick settings in `config/runtime.exs`).

## Adding to Phoenix

To add `windicss` to an application using Phoenix, you will need Phoenix v1.6+
and the following steps.

First add it as a dependency in your `mix.exs`:

```elixir
def deps do
  [
    {:phoenix, "~> 1.6"},
    {:windicss, "~> 0.1.8", runtime: Mix.env() == :dev}
  ]
end
```

Also, in `mix.exs`, add `windicss` to the `assets.deploy`
alias for deployments (with the `--minify` option):

```elixir
"assets.deploy": ["windicss default --minify", ..., "phx.digest"]
```

Now let's change `config/config.exs` to tell `windicss` to use
configuration in `assets/windicss.config.js` for building our css
bundle into `priv/static/assets`. We'll also give it our `assets/css/app.css`
as our css entry point:

```elixir
config :windicss,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=windicss.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]
```

> Make sure the "assets" directory from priv/static is listed in the
> :only option for Plug.Static in your lib/my_app_web/endpoint.ex

If your Phoenix application is using an umbrella structure, you should specify
the web application's asset directory in the configuration:

```elixir
config :windicss,
  version: "3.2.4",
  default: [
    args: ...,
    cd: Path.expand("../apps/<folder_ending_with_web>/assets", __DIR__)
  ]
```

For development, we want to enable watch mode. So find the `watchers`
configuration in your `config/dev.exs` and add:

```elixir
  windicss: {Windicss, :install_and_run, [:default, ~w(--watch)]}
```

Note we are enabling the file system watcher.

Finally, run the command:

```bash
$ mix windicss.install
```

This command installs Windicss and  updates your `assets/css/app.css`
and `assets/js/app.js` with the necessary changes to start using Windicss
right away. It also generates a default configuration file called
`assets/windicss.config.js` for you. This is the file we referenced
when we configured `windicss` in `config/config.exs`.

## Windicss Configuration

The first time this package is installed, a default windicss configuration
will be placed in a new `assets/windicss.config.js` file. See
the [windicss documentation](https://windicss.org/docs/configuration)
on configuration options.

_Note_: The stand-alone Windicss client bundles first-class windicss packages
within the precompiled executable. For third-party Windicss plugin support,
the node package must be used. See the [windicss nodejs installation instructions](https://windicss.org/docs/installation) if you require third-party plugin support.

The default windicss configuration includes Windicss variants for Phoenix LiveView specific
lifecycle classes:

* `phx-no-feedback` - applied when feedback should be hidden from the user
* `phx-click-loading` - applied when an event is sent to the server on click while the client awaits the server response
* `phx-submit-loading` - applied when a form is submitted while the client awaits the server response
* `phx-change-loading` - applied when a form input is changed while the client awaits the server response

Therefore, you may apply a variant, such as `phx-click-loading:animate-pulse` to customize windicss classes
when Phoenix LiveView classes are applied.

## License

Copyright (c) 2023 Jason Clark.
Copyright (c) 2022 Chris McCord.
Copyright (c) 2021 Wojtek Mach, José Valim.

windicss source code is licensed under the [MIT License](LICENSE.md).
