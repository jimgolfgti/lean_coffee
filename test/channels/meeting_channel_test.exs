defmodule LeanCoffee.MeetingChannelTest do
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
  test "anonymous user may join channel", %{socket: socket} do
    channel = insert_channel(insert_user())

    {:ok, reply, _socket} = subscribe_and_join(socket, "channel:#{channel.id}", %{})

    assert reply == %{topics: []}
  end

  test "join without topics replies empty list", %{socket: socket, user: user} do
    channel = insert_channel(user)

    {:ok, reply, _socket} = subscribe_and_join(socket, "channel:#{channel.id}", %{})

    assert reply == %{topics: []}
  end

  test "join with topics replies with available topics", %{socket: socket, user: user} do
    channel = insert_channel(user)
    topic = insert_topic(user, channel)

    {:ok, reply, _socket} = subscribe_and_join(socket, "channel:#{channel.id}", %{})

    assert reply == %{topics: [%{
        id: topic.id,
        subject: topic.subject,
        body: topic.body,
        user: %{id: user.id, username: LeanCoffee.LayoutView.user_name(user)}
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

  test "new_topic broadcasts to channel subscribes", %{socket: socket, user: user} do
    socket = subscribe_and_join socket

    push socket, "new_topic", %{"subject" => "my topic"}

    user_id = user.id
    user_name = LeanCoffee.LayoutView.user_name(user)
    assert_broadcast "new_topic", %{
      id: _,
      subject: "my topic",
      body: nil,
      user: %{id: ^user_id, username: ^user_name}
    }
  end

  defp subscribe_and_join(socket) do
    channel_owner = insert_user()
    channel = insert_channel(channel_owner)

    {:ok, _, socket} = subscribe_and_join(socket, "channel:#{channel.id}", %{})
    socket
  end
end