defmodule LeanCoffee.NavController do
  use LeanCoffee.Web, :controller

  alias LeanCoffee.Meetup

  def index(conn, params) do
    page =
      Meetup
      |> order_by(desc: :updated_at)
      |> Repo.paginate(params)

    render conn, "index.html",
      meetups: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    meetup = Repo.get!(Meetup, id)
    render conn, "show.html", meetup: meetup
  end
end
