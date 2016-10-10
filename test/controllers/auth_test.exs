defmodule LeanCoffee.AuthTest do
  use LeanCoffee.ConnCase
  alias LeanCoffee.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(LeanCoffee.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "init returns repo as state" do
    assert Auth.init(repo: :foo) == :foo
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %LeanCoffee.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%LeanCoffee.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets the current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)

    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and pass", %{conn: conn} do
    user = insert_user(username: "me@example.com", password: "secret")
    {:ok, conn} =
      Auth.login_by_username_and_pass(conn, "me@example.com", "secret", repo: Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_username_and_pass(conn, "me@example.com", "secret", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    insert_user(username: "me@example.com", password: "secret")

    assert {:error, :unauthorised, _conn} =
      Auth.login_by_username_and_pass(conn, "me@example.com", "incorrect", repo: Repo)
  end

  test "login with no password set", %{conn: conn} do
    Repo.insert!(%LeanCoffee.User{username: "me@example.com"})

    assert {:error, :no_password, _conn} =
      Auth.login_by_username_and_pass(conn, "me@example.com", "irrelevant", repo: Repo)
  end
end
