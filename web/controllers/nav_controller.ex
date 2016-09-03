defmodule LeanCoffee.NavController do
  use LeanCoffee.Web, :controller

  alias LeanCoffee.Channel

  def index(conn, params) do
    page =
      Channel
      |> order_by(desc: :updated_at)
      |> Repo.paginate(params)

    render conn, "index.html",
      channels: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)
    render conn, "show.html", channel: channel
  end
end
