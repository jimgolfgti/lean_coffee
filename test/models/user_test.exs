defmodule LeanCoffee.UserTest do
  use LeanCoffee.ModelCase, async: true

  alias LeanCoffee.User

  @valid_attrs %{name: "user name", password: "password", username: "user@example.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "changeset requires username is email" do
    attrs = Map.put(@valid_attrs, :username, "wrong!")

    assert {:username, "should be an email address"} in errors_on(%User{}, attrs)
  end

  test "registration_changeset password must be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)

    assert {:password, {"should be at least %{count} character(s)", count: 6}} in changeset.errors
  end

  test "registration_changeset with valid attributes hashes password" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    %{password: pass, password_hash: pass_hash} = changeset.changes

    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)
  end
end
