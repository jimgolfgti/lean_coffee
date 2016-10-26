defmodule LeanCoffee.MeetupController do
  use LeanCoffee.Web, :controller

  alias LeanCoffee.Meetup

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, params, user) do
    page =
      user_meetups(user)
      |> order_by(desc: :updated_at)
      |> Repo.paginate(params)
    render(conn, "index.html",
      meetups: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:meetups)
      |> Meetup.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meetup" => meetup_params}, user) do
    changeset =
      user
      |> build_assoc(:meetups)
      |> Meetup.changeset(meetup_params)

    case Repo.insert(changeset) do
      {:ok, _meetup} ->
        conn
        |> put_flash(:info, "Meetup created successfully.")
        |> redirect(to: meetup_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    meetup = Repo.get!(user_meetups(user), id)
    render(conn, "show.html", meetup: meetup)
  end

  def edit(conn, %{"id" => id}, user) do
    meetup = Repo.get!(user_meetups(user), id)
    changeset = Meetup.changeset(meetup)
    render(conn, "edit.html", meetup: meetup, changeset: changeset)
  end

  def update(conn, %{"id" => id, "meetup" => meetup_params}, user) do
    meetup = Repo.get!(user_meetups(user), id)
    changeset = Meetup.changeset(meetup, meetup_params)

    case Repo.update(changeset) do
      {:ok, meetup} ->
        conn
        |> put_flash(:info, "Meetup updated successfully.")
        |> redirect(to: meetup_path(conn, :show, meetup))
      {:error, changeset} ->
        render(conn, "edit.html", meetup: meetup, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    meetup = Repo.get!(user_meetups(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(meetup)

    conn
    |> put_flash(:info, "Meetup deleted successfully.")
    |> redirect(to: meetup_path(conn, :index))
  end

  defp user_meetups(user) do
    assoc(user, :meetups)
  end
end
