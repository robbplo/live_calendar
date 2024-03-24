defmodule LiveCalendarWeb.Live.CalendarLiveState do
  @moduledoc """
  This struct contains the state of the calendar live component
  """
  alias LiveCalendar.Calendar

  @enforce_keys [:calendars, :arrival, :departure]
  defstruct [:calendars, :arrival, :departure]

  @type t() :: %__MODULE__{
          calendars: %{binary => Calendar.t()},
          arrival: binary | nil,
          departure: binary | nil
        }

  @doc """
  Creates a new state with the given calendars. Arrival and departure dates are optional.
  """
  @spec new([Calendar.t()], binary | nil, binary | nil) :: t()
  def new(calendars, arrival \\ nil, departure \\ nil) do
    %__MODULE__{
      calendars: Map.new(calendars, &{to_string(&1.date), &1}),
      arrival: arrival,
      departure: departure
    }
  end

  @doc """
  Selects a date from the calendars. If the date is not found, the state is returned as is.
  Checks if the arrival and departure dates are set and updates them accordingly.
  Also ensures that all dates in the range between arrival and departure are available.
  """
  @spec select(t(), binary) :: t()
  def select(%__MODULE__{calendars: calendars} = state, date) do
    case Map.get(calendars, date) do
      nil -> state
      calendar -> state |> do_select(calendar) |> validate_range(calendar)
    end
  end

  @doc """
  Resets the arrival and departure dates to nil.
  """
  @spec reset(t()) :: t()
  def reset(state) do
    %__MODULE__{state | arrival: nil, departure: nil}
  end

  # If the arrival date is nil, set it to the selected date.
  # If the arrival date is set and the selected date is after the arrival date, set the departure
  # date. Otherwise, set the arrival date.
  @spec do_select(t(), Calendar.t()) :: t()
  defp do_select(%__MODULE__{arrival: nil} = state, calendar), do: set_arrival(state, calendar)

  defp do_select(%__MODULE__{arrival: arrival} = state, calendar) do
    with {:ok, arrival_date} <- Date.from_iso8601(arrival),
         true <- Date.after?(calendar.date, arrival_date) do
      set_departure(state, calendar)
    else
      _ -> set_arrival(state, calendar)
    end
  end

  # If the selected date is available, set it as the arrival date
  @spec set_arrival(t(), Calendar.t()) :: t()
  defp set_arrival(state, %Calendar{available: true, date: date}) do
    %__MODULE__{state | arrival: to_string(date)}
  end

  defp set_arrival(state, _), do: state

  # Set the departure date to the selected date if:
  # - The previous date was not available and the selected date is available
  # - The previous date was available
  @spec set_departure(t(), Calendar.t()) :: t()
  defp set_departure(state, %Calendar{previous_available: false, available: true, date: date}) do
    %__MODULE__{state | departure: to_string(date)}
  end

  defp set_departure(state, %Calendar{previous_available: true, date: date}) do
    %__MODULE__{state | departure: to_string(date)}
  end

  defp set_departure(state, _), do: state

  # Validate the range between the arrival and departure dates. If the range contains any
  # unavailable dates, reset the state and set the arrival date to the selected date.
  # If the arrival and departure dates are not both set, return the state as is.
  @spec validate_range(t(), Calendar.t()) :: t()
  defp validate_range(%__MODULE__{arrival: arrival, departure: departure} = state, calendar)
       when is_binary(arrival) and is_binary(departure) do
    with {:ok, arrival_date} <- Date.from_iso8601(arrival),
         {:ok, departure_date} <- Date.from_iso8601(departure),
         true <- Calendar.available_between?(arrival_date, departure_date) do
      state
    else
      _ -> state |> reset() |> set_arrival(calendar)
    end
  end

  defp validate_range(state, _), do: state
end
