defmodule LeanCoffee.LayoutView do
  use LeanCoffee.Web, :view

  def user_name(%{name: name, username: username}) when is_nil(name), do: username

  def user_name(%{name: name}), do: name

  def user_name(_), do: "Who U?"
end
