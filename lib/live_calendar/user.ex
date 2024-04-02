defmodule LiveCalendar.User do
  @moduledoc """
  User schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias LiveCalendar.Repo

  schema "users" do
    field :email, :string
    field :password, :string
    field :name, :string
    field :role, :string
    timestamps()
  end

  @type t() :: %__MODULE__{
          id: integer() | nil,
          email: String.t() | nil,
          password: String.t() | nil,
          name: String.t() | nil,
          role: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  def changeset(calendar, attrs) do
    cast(calendar, attrs, [:email, :password, :name, :role])
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
