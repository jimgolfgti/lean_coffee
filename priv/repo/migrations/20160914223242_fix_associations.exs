defmodule LeanCoffee.Repo.Migrations.FixAssociations do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE topics DROP CONSTRAINT topics_channel_id_fkey"
    alter table(:topics) do
      modify :channel_id, references(:channels, on_delete: :delete_all)
    end
    execute "ALTER TABLE topic_votes DROP CONSTRAINT topic_votes_topic_id_fkey"
    alter table(:topic_votes) do
      modify :topic_id, references(:topics, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE topics DROP CONSTRAINT topics_channel_id_fkey"
    alter table(:topics) do
      modify :channel_id, references(:channels, on_delete: :nothing)
    end
    execute "ALTER TABLE topic_votes DROP CONSTRAINT topic_votes_topic_id_fkey"
    alter table(:topic_votes) do
      modify :topic_id, references(:topics, on_delete: :nothing)
    end
  end
end
