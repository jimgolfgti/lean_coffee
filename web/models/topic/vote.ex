defmodule LeanCoffee.Topic.Vote do
  use LeanCoffee.Web, :model

  schema "topic_votes" do
    belongs_to :topic, LeanCoffee.Topic
    belongs_to :user, LeanCoffee.User

    timestamps(updated_at: false)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> unique_constraint(:topic,
      name: :topic_votes_topic_id_user_id_index,
      message: "vote for topic has already been made")
  end
end
