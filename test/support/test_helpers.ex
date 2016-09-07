defmodule LeanCoffee.TestHelpers do
  alias LeanCoffee.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
        name: "Some User",
        username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
        password: "supersecret",
      }, attrs)
    %LeanCoffee.User{}
    |> LeanCoffee.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_channel(user, attrs \\ %{}) do
    changes = Dict.merge(%{
        name: "The Name",
      }, attrs)
    user
    |> Ecto.build_assoc(:channels)
    |> LeanCoffee.Channel.changeset(changes)
    |> Repo.insert!()
  end

  def insert_topic(user, channel, attrs \\ %{}) do
    changes = Dict.merge(%{
        subject: "The Subject"
      }, attrs)
    user
    |> Ecto.build_assoc(:topics, channel_id: channel.id)
    |> LeanCoffee.Topic.changeset(changes)
    |> Repo.insert!()
  end
end
