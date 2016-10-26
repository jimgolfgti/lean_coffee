defmodule LeanCoffee.MeetupChannelTest do
  use LeanCoffee.ChannelCase

  setup config do
    if config[:anonymous] do
      {:ok, socket} = connect(LeanCoffee.UserSocket, %{"token" => ""})
      {:ok, socket: socket}
    else
      user = insert_user()
      token = Phoenix.Token.sign(LeanCoffee.Endpoint, "user socket", user.id)
      {:ok, socket} = connect(LeanCoffee.UserSocket, %{"token" => token})

      {:ok, socket: socket, user: user}
    end
  end

  @tag anonymous: true
  test "anonymous user may join meetup", %{socket: socket} do
    meetup = insert_meetup(insert_user())

    {:ok, reply, _socket} = subscribe_and_join(socket, "meetup:#{meetup.id}", %{})

    assert reply == %{topics: []}
  end

  test "join without topics replies empty list", %{socket: socket, user: user} do
    meetup = insert_meetup(user)

    {:ok, reply, _socket} = subscribe_and_join(socket, "meetup:#{meetup.id}", %{})

    assert reply == %{topics: []}
  end

  test "join with topics replies with available topics", %{socket: socket, user: user} do
    meetup = insert_meetup(user)
    topic = insert_topic(user, meetup)
    vote_for_topic user, topic

    {:ok, reply, _socket} = subscribe_and_join(socket, "meetup:#{meetup.id}", %{})

    assert reply == %{topics: [%{
        id: topic.id,
        subject: topic.subject,
        body: topic.body,
        user: %{id: user.id, username: LeanCoffee.User.display_name(user)},
        votes: [
          %{id: user.id, username: LeanCoffee.User.display_name(user)}
        ]
      }]
    }
  end

  test "new_topic with valid content returns ok", %{socket: socket} do
    socket = subscribe_and_join socket

    ref = push socket, "new_topic", %{"subject" => "a topic"}

    assert_reply ref, :ok
  end

  test "new_topic with invalid content returns errors", %{socket: socket} do
    socket = subscribe_and_join socket

    ref = push socket, "new_topic", %{"subject" => String.duplicate("a", 51)}

    assert_reply ref, :error, %{errors: %{subject: [_]}}
  end

  @tag anonymous: true
  test "anonymous may not create new_topic", %{socket: socket} do
    socket = subscribe_and_join socket

    ref = push socket, "new_topic", %{"subject" => "my topic"}

    assert_reply ref, :ok
    refute_broadcast "new_topic", %{
      id: _,
      subject: "my topic",
      body: nil,
      user: %{id: _, username: _}
    }
  end

  test "new_topic broadcasts to meetup subscribes", %{socket: socket, user: user} do
    socket = subscribe_and_join socket

    push socket, "new_topic", %{"subject" => "my topic"}

    user_id = user.id
    user_name = LeanCoffee.LayoutView.display_name(user)
    assert_broadcast "new_topic", %{
      id: _,
      subject: "my topic",
      body: nil,
      user: %{id: ^user_id, username: ^user_name},
      votes: []
    }
  end

  test "topic_vote broadcasts to meetup subscribes", %{socket: socket, user: user} do
    socket = subscribe_and_join socket
    topic = insert_topic user, socket.assigns.meetup_id

    push socket, "topic_vote", %{id: "#{topic.id}"}

    topic_id = topic.id
    this_user = %{id: user.id, username: LeanCoffee.LayoutView.display_name(user)}
    assert_broadcast "topic_update", %{
      id: ^topic_id,
      votes: [^this_user]
    }
  end

  test "duplicate topic_vote returns errors", %{socket: socket, user: user} do
    socket = subscribe_and_join socket
    topic = insert_topic user, socket.assigns.meetup_id
    vote_for_topic user, topic

    ref = push socket, "topic_vote", %{id: "#{topic.id}"}

    assert_reply ref, :error, %{errors: %{topic: [_]}}
  end

  test "topic_vote returns current votes for topic", %{socket: socket, user: user} do
    socket = subscribe_and_join socket
    topic = insert_topic user, socket.assigns.meetup_id
    another_topic = insert_topic user, socket.assigns.meetup_id
    vote_for_topic user, another_topic
    other_user = insert_user(%{name: "Other User"})
    vote_for_topic other_user, topic

    push socket, "topic_vote", %{id: "#{topic.id}"}

    topic_id = topic.id
    other_user = %{id: other_user.id, username: LeanCoffee.LayoutView.display_name(other_user)}
    this_user = %{id: user.id, username: LeanCoffee.LayoutView.display_name(user)}
    assert_broadcast "topic_update", %{
      id: ^topic_id,
      votes: [
        ^other_user,
        ^this_user
      ]
    }
  end

  defp subscribe_and_join(socket) do
    meetup_owner = insert_user()
    meetup = insert_meetup(meetup_owner)

    {:ok, _, socket} = subscribe_and_join(socket, "meetup:#{meetup.id}", %{})
    socket
  end

  defp vote_for_topic(user, topic) do
    user
    |> build_assoc(:topic_votes, topic_id: topic.id)
    |> LeanCoffee.Topic.Vote.changeset()
    |> Repo.insert!()
  end
end
