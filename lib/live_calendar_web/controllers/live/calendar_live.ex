defmodule LiveCalendarWeb.Live.CalendarLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  alias LiveCalendar.Calendar
  alias LiveCalendarWeb.Live.CalendarLiveState, as: State

  def render(assigns) do
    ~H"""
    <div class="days">
      <div class="grid grid-cols-7 gap-2 pb-3 auto-cols-auto font-medium text-center text-gray-500
    text-md dark:text-gray-400 leading-6">
        <!-- Weekday Labels -->
        <span class="h-6">Su</span>
        <span class="h-6">Mo</span>
        <span class="h-6">Tu</span>
        <span class="h-6">We</span>
        <span class="h-6">Th</span>
        <span class="h-6">Fr</span>
        <span class="h-6">Sa</span>
      </div>
      <div class="grid grid-cols-7 auto-cols-auto days-of-month gap-1">
        <div
          :for={{date, calendar} <- @state.calendars}
          class={[
            "bg-gradient-to-br from-50% to-50% aspect-content aspect-[1/1] flex justify-center
            items-center text-sm font-semibold leading-9 text-center border rounded-md",
            classes(@state, calendar)
          ]}
          phx-click="select_date"
          phx-value-date={date}
        >
          <span><%= calendar.date.day %></span>
        </div>
      </div>
    </div>
    <div class="mt-4">
      <p>Arrival Date: <%= @state.arrival %></p>
      <p>Departure Date: <%= @state.departure %></p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    state = State.new(Calendar.all())

    {:ok, assign(socket, state: state)}
  end

  def handle_event("select_date", %{"date" => date}, %{assigns: %{state: state}} = socket) do
    state = State.select(state, date)

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("select_date", _, socket), do: {:noreply, socket}

  defp classes(%State{calendars: calendars, arrival: arrival, departure: departure}, calendar) do
    [
      selection_classes(calendar, calendars[arrival], calendars[departure]),
      availability_classes(calendar)
    ]
  end

  @spec selection_classes(Calendar.t(), Calendar.t() | nil, Calendar.t() | nil) :: String.t()
  defp selection_classes(calendar, %Calendar{} = arrival, nil) do
    calendar.date == arrival.date && "!to-green-200"
  end

  defp selection_classes(calendar, %Calendar{} = arrival, %Calendar{} = departure) do
    case {Date.compare(calendar.date, arrival.date), Date.compare(calendar.date, departure.date)} do
      {:eq, _} -> "!to-green-200"
      {_, :eq} -> "!from-green-200"
      {:gt, :lt} -> "!from-green-200 !to-green-200"
      {:lt, :gt} -> "!from-green-200 !to-green-200"
      _ -> ""
    end
  end

  defp selection_classes(_, _, _) do
    ""
  end

  @spec availability_classes(Calendar.t()) :: binary
  defp availability_classes(%Calendar{available: false, previous_available: true}), do: "from-white !to-red-200"
  defp availability_classes(%Calendar{available: false, previous_available: false}), do: "bg-red-200 text-gray-400"
  defp availability_classes(%Calendar{available: true, previous_available: false}), do: "!from-red-200 to-white"
  defp availability_classes(%Calendar{available: true, previous_available: true}), do: "from-white to-white"
end
