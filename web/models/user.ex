defmodule LeanCoffee.User do
  use LeanCoffee.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :channels, LeanCoffee.Channel
    has_many :topics, LeanCoffee.Topic
    has_many :topic_votes, LeanCoffee.Topic.Vote

    timestamps()
  end

  def display_name(%{name: name, username: username}) when is_nil(name), do: username
  def display_name(%{name: name}), do: name

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :name])
    |> unique_constraint(:username)
    |> validate_required([:username])
    |> validate_format(:username, ~r/.+@.+/, message: "should be an email address")
  end

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
        _ -> changeset
     end
  end
end
