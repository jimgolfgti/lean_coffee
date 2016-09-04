use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lean_coffee, LeanCoffee.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :lean_coffee, LeanCoffee.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "password",
  database: "lean_coffee_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

if File.exists?("test.travis.exs") do
  import_config("test.travis.exs")
end
