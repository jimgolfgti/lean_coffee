defmodule LeanCoffee.Repo do
  use Ecto.Repo, otp_app: :lean_coffee
  use Scrivener, page_size: 10
end
