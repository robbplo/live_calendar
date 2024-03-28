defmodule LiveCalendar.Repo.Migrations.CreateCalendarsTable do
  use Ecto.Migration

  def change do
    create table(:calendars) do
      add :date, :date
      add :available, :boolean
      add :minimum_stay, :integer
      timestamps()
    end
  end
end
