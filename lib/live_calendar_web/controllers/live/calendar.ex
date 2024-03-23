defmodule LiveCalendarWeb.Live.Calendar do
  @moduledoc false
  defstruct [:date, :available, :previous_available, :next_available]

  @type t() :: %__MODULE__{
          date: Date.t(),
          available: boolean,
          previous_available: boolean,
          next_available: boolean
        }


  @spec list_calendars() :: [t()]
  def list_calendars do
    list_dates()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&process_chunk/1)
  end

  defp process_chunk([{_, previous_available}, {date, available}, {_, next_available}]) do
    new(date, available, previous_available, next_available)
  end

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

  @spec new(Date.t(), boolean, boolean, boolean) :: t()
  def new(date, available, previous_available, next_available) do
    %__MODULE__{
      date: date,
      available: available,
      previous_available: previous_available,
      next_available: next_available
    }
  end
end
