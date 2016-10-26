defmodule LeanCoffee.Repo.Migrations.RenameChannels do
  use Ecto.Migration

  def up do
    rename table(:channels), to: table(:meetups)
    execute "ALTER TABLE meetups RENAME CONSTRAINT channels_user_id_fkey TO meetups_user_id_fkey"
    execute "ALTER INDEX channels_slug_index RENAME TO meetups_slug_index"
    execute "ALTER INDEX channels_user_id_index RENAME TO meetups_user_id_index"

    rename table(:topics), :channel_id, to: :meetup_id
    execute "ALTER TABLE topics RENAME CONSTRAINT topics_channel_id_fkey TO topics_meetup_id_fkey"
    execute "ALTER INDEX topics_channel_id_index RENAME TO topics_meetup_id_index"
  end

  def down do
    rename table(:meetups), to: table(:channels)
    execute "ALTER TABLE channels RENAME CONSTRAINT meetups_user_id_fkey TO channels_user_id_fkey"
    execute "ALTER INDEX meetups_slug_index RENAME TO channels_slug_index"
    execute "ALTER INDEX meetups_user_id_index RENAME TO channels_user_id_index"

    rename table(:topics), :meetup_id, to: :channel_id
    execute "ALTER TABLE topics RENAME CONSTRAINT topics_meetup_id_fkey TO topics_channel_id_fkey"
    execute "ALTER INDEX topics_meetup_id_index RENAME TO topics_channel_id_index"
  end
end
