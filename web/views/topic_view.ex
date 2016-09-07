defmodule LeanCoffee.TopicView do
  use LeanCoffee.Web, :view

  def render("topic.json", %{topic: topic}) do
    %{
      id: topic.id,
      subject: topic.subject,
      body: topic.body,
      user: render_one(topic.user, LeanCoffee.UserView, "user.json")
    }
  end
end
