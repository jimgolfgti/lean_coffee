# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lean_coffee,
  ecto_repos: [LeanCoffee.Repo]

# Configures the endpoint
config :lean_coffee, LeanCoffee.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IUqM3WJCzPh+rtJjtQxCybx0nONJWG/LYgM6m4mncKCoaZIN1AZAS0qRsZBz251Q",
  render_errors: [view: LeanCoffee.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LeanCoffee.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
