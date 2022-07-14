defmodule Chat.Repo.Migrations.CreateMain do
  use Ecto.Migration

  def change do
    create table(:main) do
      add :name, :string

      timestamps()
    end
  end
end
