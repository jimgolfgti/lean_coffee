defmodule LeanCoffee.MeetupControllerTest do
  use LeanCoffee.ConnCase

  alias LeanCoffee.Meetup
  @valid_attrs %{name: "some meetup"}
  @invalid_attrs %{name: ""}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, meetup_path(conn, :new)),
      get(conn, meetup_path(conn, :index)),
      get(conn, meetup_path(conn, :show, "123")),
      get(conn, meetup_path(conn, :edit, "123")),
      put(conn, meetup_path(conn, :update, "123", %{})),
      post(conn, meetup_path(conn, :create, %{})),
      delete(conn, meetup_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "user@example.com"
  test "lists all user's meetups on index", %{conn: conn, user: user} do
    user_meetup = insert_meetup(user, name: "my meetup")
    other_meetup = insert_meetup(insert_user(username: "other@example.com"), name: "another meetup")

    conn = get conn, meetup_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing meetups"
    assert String.contains?(conn.resp_body, user_meetup.name)
    refute String.contains?(conn.resp_body, other_meetup.name)
  end

  @tag login_as: "user@example.com"
  test "index renders a page at a time", %{conn: conn, user: user} do
    for i <- 1..15, do: insert_meetup(user, name: List.to_string(:io_lib.format("meetup_~2..0B", [i])))

    conn = get conn, meetup_path(conn, :index, %{page: 2})
    assert html_response(conn, 200) =~ "Listing meetups"
    assert String.contains?(conn.resp_body, "meetup_05")
    assert String.contains?(conn.resp_body, "meetup_04")
    assert String.contains?(conn.resp_body, "meetup_03")
    assert String.contains?(conn.resp_body, "meetup_02")
    assert String.contains?(conn.resp_body, "meetup_01")
    refute String.contains?(conn.resp_body, "meetup_06")
  end

  @tag login_as: "user@example.com"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, meetup_path(conn, :new)
    assert html_response(conn, 200) =~ "New meetup"
  end

  @tag login_as: "user@example.com"
  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = post conn, meetup_path(conn, :create), meetup: @valid_attrs
    assert redirected_to(conn) == meetup_path(conn, :index)
    assert Repo.get_by(Meetup, @valid_attrs).user_id == user.id
  end

  @tag login_as: "user@example.com"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    count_before = meetup_count(Meetup)
    conn = post conn, meetup_path(conn, :create), meetup: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert meetup_count(Meetup) == count_before
  end

  defp meetup_count(query), do: Repo.one(from c in query, select: count(c.id))

  @tag login_as: "user@example.com"
  test "shows chosen resource", %{conn: conn, user: user} do
    meetup = insert_meetup(user)
    conn = get conn, meetup_path(conn, :show, meetup)
    assert html_response(conn, 200) =~ "Show meetup"
  end

  @tag login_as: "user@example.com"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, meetup_path(conn, :show, -1)
    end
  end

  @tag login_as: "user@example.com"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    meetup = insert_meetup(user)
    conn = get conn, meetup_path(conn, :edit, meetup)
    assert html_response(conn, 200) =~ "Edit meetup"
  end

  @tag login_as: "user@example.com"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    meetup = insert_meetup(user)
    conn = put conn, meetup_path(conn, :update, meetup), meetup: @valid_attrs
    meetup = Repo.get_by(Meetup, @valid_attrs)
    assert redirected_to(conn) == meetup_path(conn, :show, meetup)
  end

  @tag login_as: "user@example.com"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    meetup = insert_meetup(user)
    conn = put conn, meetup_path(conn, :update, meetup), meetup: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit meetup"
  end

  @tag login_as: "user@example.com"
  test "deletes chosen resource", %{conn: conn, user: user} do
    meetup = insert_meetup(user)
    conn = delete conn, meetup_path(conn, :delete, meetup)
    assert redirected_to(conn) == meetup_path(conn, :index)
    refute Repo.get(Meetup, meetup.id)
  end

  @tag login_as: "user@example.com"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    meetup = insert_meetup(owner, @valid_attrs)
    non_owner = insert_user(username: "other@example.com")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, meetup_path(conn, :show, meetup))
    end
    assert_error_sent :not_found, fn ->
      get(conn, meetup_path(conn, :edit, meetup))
    end
    assert_error_sent :not_found, fn ->
      put(conn, meetup_path(conn, :update, meetup, meetup: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, meetup_path(conn, :delete, meetup))
    end
  end
end
