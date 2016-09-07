defmodule LeanCoffee.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :subject, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps()
    end
    create index(:topics, [:user_id])
    create index(:topics, [:channel_id])

  end
end
