defmodule LeanCoffee.LayoutView do
  use LeanCoffee.Web, :view

  def display_name(user), do: LeanCoffee.User.display_name(user)
end
