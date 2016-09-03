defmodule LeanCoffee.NavControllerTest do
  use LeanCoffee.ConnCase

  test "index shows a page at a time", %{conn: conn} do
    user = insert_user()
    for i <- 1..11, do: insert_channel(user, name: List.to_string(:io_lib.format("channel_~2..0B", [i])))

    conn = get conn, nav_path(conn, :index)
    assert html_response(conn, 200) =~ "Channels"
    assert length(Regex.scan(~r/channel_\d{2}/, conn.resp_body)) == 10
    refute String.contains?(conn.resp_body, "New channel")
  end

  test "index when logged in shows new channel link", %{conn: conn} do
    conn = assign(conn, :current_user, insert_user())

    conn = get conn, nav_path(conn, :index)
    assert html_response(conn, 200) =~ "New channel"
  end

  test "show renders selected channel", %{conn: conn} do
    channel = insert_channel(insert_user())

    conn = get conn, nav_path(conn, :show, channel)
    assert html_response(conn, 200) =~ channel.name
  end
end
