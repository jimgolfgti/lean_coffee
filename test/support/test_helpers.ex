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

  def insert_meetup(user, attrs \\ %{}) do
    changes = Dict.merge(%{
        name: "The Name",
      }, attrs)
    user
    |> Ecto.build_assoc(:meetups)
    |> LeanCoffee.Meetup.changeset(changes)
    |> Repo.insert!()
  end

  def insert_topic(user, meetup, attrs \\ %{})
  def insert_topic(user, %LeanCoffee.Meetup{} = meetup, attrs) do
    insert_topic(user, meetup.id, attrs)
  end
  def insert_topic(user, meetup_id, attrs) when is_integer(meetup_id) do
    changes = Dict.merge(%{
        subject: "The Subject"
      }, attrs)
    user
    |> Ecto.build_assoc(:topics, meetup_id: meetup_id)
    |> LeanCoffee.Topic.changeset(changes)
    |> Repo.insert!()
  end
end
