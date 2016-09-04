defmodule LeanCoffee.OAuthController do
  use LeanCoffee.Web, :controller
  use OAuth2.Strategy

  @google_apis "https://www.googleapis.com"

  def index(conn, _params) do
    redirect conn,
      external: OAuth2.Client.authorize_url!(client(), scope: @google_apis <> "/auth/userinfo.email")
  end

  def callback(conn, %{"code" => code}) do
    token = OAuth2.Client.get_token!(client(), code: code)
    {:ok, %{body: person}} = OAuth2.Client.get(token, @google_apis <> "/plus/v1/people/me/openIdConnect")
    user = Repo.get_by(LeanCoffee.User, username: person["email"])
    conn = cond do
      user ->
        LeanCoffee.Auth.login(conn, user)
        |> put_flash(:info, "Welcome back!")
      true ->
        create_user(conn, person)
    end

    conn
    |> redirect(to: page_path(conn, :index))
  end

  defp client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token",
      redirect_uri: oauth_url(LeanCoffee.Endpoint, :callback),
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
    ])
  end

  defp create_user(conn, person) do
    user = make_user(person["email"], "")
    case Repo.insert(user) do
      {:ok, user} ->
        conn
        |> LeanCoffee.Auth.login(user)
        |> put_flash(:info, "#{user.username} registered successfully.")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. Please have another go")
    end
  end

  defp make_user(username, "") do
    %LeanCoffee.User{username: username}
  end
  defp make_user(username, name) do
    %LeanCoffee.User{username: username, name: name}
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_param(:client_secret, client.client_secret)
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
    |> put_param(:response_type, "")
  end
end
