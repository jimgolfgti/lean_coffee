defmodule LeanCoffee.Router do
  use LeanCoffee.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LeanCoffee.Auth, repo: LeanCoffee.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LeanCoffee do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/manage", LeanCoffee do
    pipe_through [:browser, :authenticate_user]

    resources "/channels", ChannelController
  end
end
