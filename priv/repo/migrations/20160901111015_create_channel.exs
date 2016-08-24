defmodule LeanCoffee.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :slug, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:channels, [:slug])
    create index(:channels, [:user_id])
  end
end
