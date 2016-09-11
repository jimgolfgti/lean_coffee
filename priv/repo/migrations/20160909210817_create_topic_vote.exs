defmodule LeanCoffee.Repo.Migrations.CreateTopic.Vote do
  use Ecto.Migration

  def change do
    create table(:topic_votes) do
      add :topic_id, references(:topics, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(updated_at: false)
    end
    create unique_index(:topic_votes, [:topic_id, :user_id])

  end
end
