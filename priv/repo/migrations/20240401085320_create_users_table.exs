defmodule LiveCalendar.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      add :name, :string
      add :role, :string
      timestamps()
    end
  end
end
