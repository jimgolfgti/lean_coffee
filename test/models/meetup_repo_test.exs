defmodule LeanCoffee.MeetupRepoTest do
  use LeanCoffee.ModelCase
  alias LeanCoffee.Meetup

  @valid_attrs %{name: "September 2016"}

  test "converts unique_constraint on name to error" do
    insert_meetup(insert_user(), name: "September 2016")
    changeset = Meetup.changeset(%Meetup{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:slug, {"has already been taken, please update Name", []}} in changeset.errors
  end
end
