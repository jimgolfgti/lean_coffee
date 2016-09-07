defmodule LeanCoffee.MeetingChannel do
  use LeanCoffee.Web, :channel

  alias LeanCoffee.{ChangesetView,TopicView,UserView}

  def join("channel:" <> channel_id, _params, socket) do
    channel_id = String.to_integer(channel_id)
    channel = Repo.get!(LeanCoffee.Channel, channel_id)

    topics = Repo.all(
      from t in assoc(channel, :topics),
      order_by: [asc: t.subject],
      limit: 20,
      preload: [:user]
    )
    resp = %{topics: Phoenix.View.render_many(topics, TopicView, "topic.json")}

    {:ok, resp, assign(socket, :channel_id, channel_id)}
  end

  def handle_in(event, params, socket) do
    case socket.assigns.user_id do
      "anon" ->
        {:reply, :ok, socket}
      user_id ->
        user = Repo.get(LeanCoffee.User, user_id)
        handle_in(event, params, user, socket)
    end
  end

  def handle_in("new_topic", params, user, socket) do
    changeset =
      user
      |> build_assoc(:topics, channel_id: socket.assigns.channel_id)
      |> LeanCoffee.Topic.changeset(params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        broadcast! socket, "new_topic", %{
          id: topic.id,
          user: UserView.render("user.json", %{user: user}),
          subject: topic.subject,
          body: topic.body
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {
          :error, ChangesetView.render("error.json", %{
            changeset: changeset
          })}, socket}
    end
  end
end
