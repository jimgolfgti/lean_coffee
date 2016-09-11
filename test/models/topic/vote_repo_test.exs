defmodule LeanCoffee.Topic.VoteTest do
  use LeanCoffee.ModelCase

  test "converts unique_constraint on topic and user to error" do
    user = insert_user(username: "user@example.com")
    channel = insert_channel(user)
    topic = insert_topic(user, channel)
    user
    |> build_assoc(:topic_votes, topic_id: topic.id)
    |> Repo.insert!()

    changeset = user
    |> build_assoc(:topic_votes, topic_id: topic.id)
    |> LeanCoffee.Topic.Vote.changeset()

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:topic, {"vote for topic has already been made", []}} in changeset.errors
  end
end
