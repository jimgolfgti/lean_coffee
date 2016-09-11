defmodule LeanCoffee.TopicVoteView do
  use LeanCoffee.Web, :view

  def render("vote.json", %{topic_vote: vote}) do
    %{
      id: vote.user.id,
      username: LeanCoffee.User.user_name(vote.user)
    }
  end
end
