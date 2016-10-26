defmodule LeanCoffee.NavControllerTest do
  use LeanCoffee.ConnCase

  test "index shows a page at a time", %{conn: conn} do
    user = insert_user()
    for i <- 1..11, do: insert_meetup(user, name: List.to_string(:io_lib.format("meetup_~2..0B", [i])))

    conn = get conn, nav_path(conn, :index)
    assert html_response(conn, 200) =~ "Meetups"
    assert length(Regex.scan(~r/meetup_\d{2}/, conn.resp_body)) == 10
    refute String.contains?(conn.resp_body, "New meetup")
  end

  test "index when logged in shows new meetup link", %{conn: conn} do
    conn = assign(conn, :current_user, insert_user())

    conn = get conn, nav_path(conn, :index)
    assert html_response(conn, 200) =~ "New meetup"
  end

  test "show renders selected meetup", %{conn: conn} do
    meetup = insert_meetup(insert_user())

    conn = get conn, nav_path(conn, :show, meetup)
    assert html_response(conn, 200) =~ meetup.name
  end
end
