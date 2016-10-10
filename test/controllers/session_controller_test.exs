defmodule LeanCoffee.SessionControllerTest do
  use LeanCoffee.ConnCase
  alias LeanCoffee.{Repo,User}

  test "renders form for login", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "redirects to home with valid credentials", %{conn: conn} do
    user = insert_user()
    conn = post conn, session_path(conn, :create), session: %{"username": user.username, "password": user.password}

    assert conn.assigns.current_user
    assert get_flash(conn, :info) == "Welcome back!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not login and returns error with invalid credentials", %{conn: conn} do
    user = insert_user()
    conn = post conn, session_path(conn, :create), session: %{"username": user.username, "password": "wrong!"}

    refute conn.assigns.current_user
    assert get_flash(conn, :error) == "Invalid username/password combination"
    assert html_response(conn, 200) =~ "Login"
  end

  test "does not login and returns error with oauth credentials", %{conn: conn} do
    user = %User{} |> User.changeset(%{username: "foo@example.com"}) |> Repo.insert!
    conn = post conn, session_path(conn, :create), session: %{"username": user.username, "password": "meh"}

    refute conn.assigns.current_user
    assert get_flash(conn, :error) == "No password set, use Google Sign-in"
    assert html_response(conn, 200) =~ "Login"
  end

  test "logs out and redirects to home", %{conn: conn} do
    user = insert_user()
    conn = assign(conn, :current_user, user)
    conn = delete conn, session_path(conn, :delete, user)

    assert conn.private.plug_session_info == :drop
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
