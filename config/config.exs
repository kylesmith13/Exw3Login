# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :metamask_login,
  ecto_repos: [MetamaskLogin.Repo]

# Configures the endpoint
config :metamask_login, MetamaskLoginWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MetamaskLoginWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MetamaskLogin.PubSub,
  live_view: [signing_salt: "4CLrU/n1"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :metamask_login, MetamaskLogin.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# so we can hide this on our production systems to prevent spoofing
config :metamask_login,
  sign_message: "57656C636F6D6520746F20456C69786972204D6574616D61736B204C6F67696E2120436C69636B205369676E20746F207369676E20696E"
