defmodule Saturday.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :booking_date, :date
      add :agent_name, :string
      add :agent_phone, :string
      add :created_at, :date
      add :misc, :string

      timestamps()
    end
  end
end
