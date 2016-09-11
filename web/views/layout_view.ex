defmodule LeanCoffee.LayoutView do
  use LeanCoffee.Web, :view

  def user_name(user), do: LeanCoffee.User.user_name(user)
end
