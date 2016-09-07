defmodule LeanCoffee.Channel do
  use LeanCoffee.Web, :model

  @primary_key {:id, LeanCoffee.Permalink, autogenerate: true}
  schema "channels" do
    field :name, :string
    field :slug, :string
    belongs_to :user, LeanCoffee.User
    has_many :topics, LeanCoffee.Topic

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> gen_slug()
    |> unique_constraint(:slug, message: "has already been taken, please update Name")
  end

  defp gen_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{name: name}} ->
        put_change(changeset, :slug, name |> String.downcase |> String.replace(~r/[\W_]+/, "-"))
        _ -> changeset
     end
  end
end

defimpl Phoenix.Param, for: LeanCoffee.Channel do
  def to_param(%{id: id, slug: slug}) do
    "#{id}-#{slug}"
  end
end
