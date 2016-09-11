defmodule LeanCoffee.TopicTest do
  use LeanCoffee.ModelCase, async: true

  alias LeanCoffee.Topic

  @valid_attrs %{subject: "something something something"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Topic.changeset(%Topic{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Topic.changeset(%Topic{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset requires subject no longer than 50" do
    attrs = %{subject: String.duplicate("a", 51)}

    assert {:subject, "should be at most 50 character(s)"} in errors_on(%Topic{}, attrs)
  end

  test "changeset requires body no longer than 50" do
    attrs = Map.put(@valid_attrs, :body, String.duplicate("a", 501))

    assert {:body, "should be at most 500 character(s)"} in errors_on(%Topic{}, attrs)
  end
end
