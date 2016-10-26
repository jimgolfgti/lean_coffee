defmodule LeanCoffee.MeetupTest do
  use LeanCoffee.ModelCase, async: true

  alias LeanCoffee.Meetup

  @valid_attrs %{name: "some content", slug: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Meetup.changeset(%Meetup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Meetup.changeset(%Meetup{}, @invalid_attrs)
    refute changeset.valid?
  end
end
