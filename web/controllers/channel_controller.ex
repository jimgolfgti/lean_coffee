defmodule LeanCoffee.ChannelController do
  use LeanCoffee.Web, :controller

  alias LeanCoffee.Channel

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, params, user) do
    page =
      user_channels(user)
      |> order_by(desc: :updated_at)
      |> Repo.paginate(params)
    render(conn, "index.html",
      channels: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:channels)
      |> Channel.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"channel" => channel_params}, user) do
    changeset =
      user
      |> build_assoc(:channels)
      |> Channel.changeset(channel_params)

    case Repo.insert(changeset) do
      {:ok, _channel} ->
        conn
        |> put_flash(:info, "Channel created successfully.")
        |> redirect(to: channel_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    channel = Repo.get!(user_channels(user), id)
    render(conn, "show.html", channel: channel)
  end

  def edit(conn, %{"id" => id}, user) do
    channel = Repo.get!(user_channels(user), id)
    changeset = Channel.changeset(channel)
    render(conn, "edit.html", channel: channel, changeset: changeset)
  end

  def update(conn, %{"id" => id, "channel" => channel_params}, user) do
    channel = Repo.get!(user_channels(user), id)
    changeset = Channel.changeset(channel, channel_params)

    case Repo.update(changeset) do
      {:ok, channel} ->
        conn
        |> put_flash(:info, "Channel updated successfully.")
        |> redirect(to: channel_path(conn, :show, channel))
      {:error, changeset} ->
        render(conn, "edit.html", channel: channel, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    channel = Repo.get!(user_channels(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(channel)

    conn
    |> put_flash(:info, "Channel deleted successfully.")
    |> redirect(to: channel_path(conn, :index))
  end

  defp user_channels(user) do
    assoc(user, :channels)
  end
end
