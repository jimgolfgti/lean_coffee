defmodule LeanCoffee.UserView do
  use LeanCoffee.Web, :view

  def render("user.json", %{user: user}) do
    %{id: user.id, username: LeanCoffee.LayoutView.user_name(user)}
  end
end
