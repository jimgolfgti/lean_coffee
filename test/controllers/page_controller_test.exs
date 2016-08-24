defmodule LeanCoffee.PageControllerTest do
  use LeanCoffee.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Lean Coffee"
  end
end
