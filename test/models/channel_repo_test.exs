defmodule LeanCoffee.ChannelRepoTest do
  use LeanCoffee.ModelCase
  alias LeanCoffee.Channel

  @valid_attrs %{name: "September 2016"}

  test "converts unique_constraint on name to error" do
    insert_channel(insert_user(), name: "September 2016")
    changeset = Channel.changeset(%Channel{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:slug, {"has already been taken, please update Name", []}} in changeset.errors
  end
end
