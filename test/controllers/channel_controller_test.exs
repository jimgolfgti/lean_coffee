defmodule LeanCoffee.ChannelControllerTest do
  use LeanCoffee.ConnCase

  alias LeanCoffee.Channel
  @valid_attrs %{name: "some channel"}
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
      get(conn, channel_path(conn, :new)),
      get(conn, channel_path(conn, :index)),
      get(conn, channel_path(conn, :show, "123")),
      get(conn, channel_path(conn, :edit, "123")),
      put(conn, channel_path(conn, :update, "123", %{})),
      post(conn, channel_path(conn, :create, %{})),
      delete(conn, channel_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "user@example.com"
  test "lists all user's channels on index", %{conn: conn, user: user} do
    user_channel = insert_channel(user, name: "my channel")
    other_channel = insert_channel(insert_user(username: "other@example.com"), name: "another channel")

    conn = get conn, channel_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing channels"
    assert String.contains?(conn.resp_body, user_channel.name)
    refute String.contains?(conn.resp_body, other_channel.name)
  end

  @tag login_as: "user@example.com"
  test "index renders a page at a time", %{conn: conn, user: user} do
    for i <- 1..15, do: insert_channel(user, name: List.to_string(:io_lib.format("channel_~2..0B", [i])))

    conn = get conn, channel_path(conn, :index, %{page: 2})
    assert html_response(conn, 200) =~ "Listing channels"
    assert String.contains?(conn.resp_body, "channel_05")
    assert String.contains?(conn.resp_body, "channel_04")
    assert String.contains?(conn.resp_body, "channel_03")
    assert String.contains?(conn.resp_body, "channel_02")
    assert String.contains?(conn.resp_body, "channel_01")
    refute String.contains?(conn.resp_body, "channel_06")
  end

  @tag login_as: "user@example.com"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, channel_path(conn, :new)
    assert html_response(conn, 200) =~ "New channel"
  end

  @tag login_as: "user@example.com"
  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = post conn, channel_path(conn, :create), channel: @valid_attrs
    assert redirected_to(conn) == channel_path(conn, :index)
    assert Repo.get_by(Channel, @valid_attrs).user_id == user.id
  end

  @tag login_as: "user@example.com"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    count_before = channel_count(Channel)
    conn = post conn, channel_path(conn, :create), channel: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert channel_count(Channel) == count_before
  end

  defp channel_count(query), do: Repo.one(from c in query, select: count(c.id))

  @tag login_as: "user@example.com"
  test "shows chosen resource", %{conn: conn, user: user} do
    channel = insert_channel(user)
    conn = get conn, channel_path(conn, :show, channel)
    assert html_response(conn, 200) =~ "Show channel"
  end

  @tag login_as: "user@example.com"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, channel_path(conn, :show, -1)
    end
  end

  @tag login_as: "user@example.com"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    channel = insert_channel(user)
    conn = get conn, channel_path(conn, :edit, channel)
    assert html_response(conn, 200) =~ "Edit channel"
  end

  @tag login_as: "user@example.com"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    channel = insert_channel(user)
    conn = put conn, channel_path(conn, :update, channel), channel: @valid_attrs
    assert redirected_to(conn) == channel_path(conn, :show, channel)
    assert Repo.get_by(Channel, @valid_attrs)
  end

  @tag login_as: "user@example.com"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    channel = insert_channel(user)
    conn = put conn, channel_path(conn, :update, channel), channel: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit channel"
  end

  @tag login_as: "user@example.com"
  test "deletes chosen resource", %{conn: conn, user: user} do
    channel = insert_channel(user)
    conn = delete conn, channel_path(conn, :delete, channel)
    assert redirected_to(conn) == channel_path(conn, :index)
    refute Repo.get(Channel, channel.id)
  end

  @tag login_as: "user@example.com"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    channel = insert_channel(owner, @valid_attrs)
    non_owner = insert_user(username: "other@example.com")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, channel_path(conn, :show, channel))
    end
    assert_error_sent :not_found, fn ->
      get(conn, channel_path(conn, :edit, channel))
    end
    assert_error_sent :not_found, fn ->
      put(conn, channel_path(conn, :update, channel, channel: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, channel_path(conn, :delete, channel))
    end
  end
end
