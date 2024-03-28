defmodule LiveCalendar.Calendar do
  @moduledoc """
  This module is responsible for managing the calendar data.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias LiveCalendar.Repo

  schema "calendars" do
    field :date, :date
    field :available, :boolean
    field :minimum_stay, :integer
    timestamps()
  end

  @type t() :: %__MODULE__{
          date: Date.t() | nil,
          available: boolean | nil,
          minimum_stay: integer | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:date, :available, :minimum_stay])
    |> validate_required([:date, :available, :minimum_stay])
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
