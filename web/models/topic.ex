defmodule LeanCoffee.Topic do
  use LeanCoffee.Web, :model

  schema "topics" do
    field :subject, :string
    field :body, :string
    belongs_to :user, LeanCoffee.User
    belongs_to :channel, LeanCoffee.Channel

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject, :body])
    |> validate_required([:subject])
    |> validate_length(:subject, max: 50)
    |> validate_length(:body, max: 500)
  end
end
