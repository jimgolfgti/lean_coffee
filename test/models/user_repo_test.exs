defmodule LeanCoffee.UserRepoTest do
  use LeanCoffee.ModelCase
  alias LeanCoffee.User

  @valid_attrs %{name: "A User", username: "user@example.com"}

  test "converts unique_constraint on username to error" do
    insert_user(username: "user@example.com")
    changeset = User.changeset(%User{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end
