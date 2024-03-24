defmodule LiveCalendar.Calendar do
  @moduledoc """
  This module is responsible for managing the calendar data.
  """

  defstruct [:date, :available, :previous_available]

  @type t() :: %__MODULE__{
          date: Date.t(),
          available: boolean,
          previous_available: boolean
        }

  @spec new(Date.t(), boolean, boolean) :: t()
  def new(date, available, previous_available) do
    %__MODULE__{
      date: date,
      available: available,
      previous_available: previous_available
    }
  end

  @spec all() :: [t()]
  def all do
    list_dates()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{_, previous}, {date, available}] -> new(date, available, previous) end)
  end

  @spec available_between?(Date.t() | binary, Date.t() | binary) :: boolean
  def available_between?(from, to) when is_binary(from) and is_binary(to) do
    case {Date.from_iso8601(from), Date.from_iso8601(to)} do
      {{:ok, from}, {:ok, to}} -> available_between?(from, to)
      _ -> false
    end
  end

  def available_between?(from, to) do
    all()
    |> Enum.filter(fn %{date: date} -> date in Date.range(from, to) end)
    |> do_available_between?()
  end

  @spec do_available_between?([t()], boolean) :: boolean
  defp do_available_between?(calendars, acc \\ true)
  # Return false if any date is not available
  defp do_available_between?(_, false), do: false
  # Return accumulator if all dates are available
  defp do_available_between?([], acc), do: acc

  # For the last date, only the previous date needs to be available
  defp do_available_between?([last], acc) do
    acc and last.previous_available
  end

  defp do_available_between?([first | rest], acc) do
    do_available_between?(rest, acc and first.available)
  end

  # substitute for the database
  defp list_dates do
    [
      {~D[2024-02-28], true},
      {~D[2024-03-01], true},
      {~D[2024-03-02], true},
      {~D[2024-03-03], true},
      {~D[2024-03-04], false},
      {~D[2024-03-05], false},
      {~D[2024-03-06], false},
      {~D[2024-03-07], false},
      {~D[2024-03-08], true},
      {~D[2024-03-09], true},
      {~D[2024-03-10], true},
      {~D[2024-03-11], true},
      {~D[2024-03-12], true},
      {~D[2024-03-13], true},
      {~D[2024-03-14], true},
      {~D[2024-03-15], true},
      {~D[2024-03-16], true},
      {~D[2024-03-17], true},
      {~D[2024-03-18], true},
      {~D[2024-03-19], true},
      {~D[2024-03-20], true},
      {~D[2024-03-21], true},
      {~D[2024-03-22], true},
      {~D[2024-03-23], true},
      {~D[2024-03-24], true},
      {~D[2024-03-25], true},
      {~D[2024-03-26], true},
      {~D[2024-03-27], true},
      {~D[2024-03-28], true},
      {~D[2024-03-29], true},
      {~D[2024-03-30], true},
      {~D[2024-03-31], true},
      {~D[2024-04-01], true}
    ]
  end
end
