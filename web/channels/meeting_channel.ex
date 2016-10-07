defmodule LeanCoffee.MeetingChannel do
  use LeanCoffee.Web, :channel

  alias LeanCoffee.{Channel,Topic,User}
  alias LeanCoffee.Topic.Vote
  alias LeanCoffee.{ChangesetView,TopicView,UserView}

  def join("channel:" <> channel_id, _params, socket) do
    channel_id = String.to_integer(channel_id)
    channel = Repo.get!(Channel, channel_id)

    votes_query =
      from v in Vote,
      order_by: v.inserted_at,
      preload: [:user]
    topics = Repo.all(
      from t in assoc(channel, :topics),
      order_by: [asc: t.subject],
      limit: 20,
      preload: [:user, votes: ^votes_query]
    )
    resp = %{topics: Phoenix.View.render_many(topics, TopicView, "topic.json")}

    send(self, :after_join)
    {:ok, resp, assign(socket, :channel_id, channel_id)}
  end

  def handle_in(event, params, socket) do
    case socket.assigns.user_id do
      :anon ->
        {:reply, :ok, socket}
      user_id ->
        user = Repo.get(User, user_id)
        handle_in(event, params, user, socket)
    end
  end

  def handle_in("new_topic", params, user, socket) do
    changeset =
      user
      |> build_assoc(:topics, channel_id: socket.assigns.channel_id)
      |> Topic.changeset(params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        broadcast! socket, "new_topic", %{
          id: topic.id,
          user: UserView.render("user.json", %{user: user}),
          subject: topic.subject,
          body: topic.body,
          votes: []
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {
          :error, ChangesetView.render("error.json", %{
            changeset: changeset
            })
          }, socket}
    end
  end

  def handle_in("topic_vote", %{"id" => id}, user, socket) do
    topic_id = String.to_integer(id)
    changeset =
      user
      |> build_assoc(:topic_votes, topic_id: topic_id)
      |> Vote.changeset()

    case Repo.insert(changeset) do
      {:ok, _changeset} ->
        votes = Repo.all(
          from v in Vote,
          join: u in User, on: v.user_id == u.id,
          where: [topic_id: ^topic_id],
          order_by: [asc: :id],
          select: %{id: u.id, name: u.name, username: u.username}
        )

        broadcast! socket, "topic_update", %{
          id: topic_id,
          votes: Enum.map(votes, &(%{id: &1.id, username: User.display_name(&1)}))
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {
          :error, ChangesetView.render("error.json", %{
            changeset: changeset
            })
          }, socket}
    end
  end

  def handle_info(:after_join, socket) do
    track_user socket
    push socket, "presence_state", LeanCoffee.Presence.list(socket)
    {:noreply, socket}
  end

  defp track_user(socket = %{assigns: %{user_id: :anon}}), do: :ok
  defp track_user(socket = %{assigns: %{user_id: user_id}}) do
    {:ok, _} = LeanCoffee.Presence.track(socket, user_id, %{
      online_at: System.system_time(:milli_seconds)
    })
    :ok
  end
end
