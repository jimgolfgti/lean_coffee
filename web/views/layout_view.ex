defmodule LeanCoffee.LayoutView do
  use LeanCoffee.Web, :view

  def user_name(%{name: name}), do: name

  def user_name(%{username: username}), do: username

  def user_name(_), do: "Who U?"
end
