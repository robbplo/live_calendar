defmodule LiveCalendarWeb.Live.CalendarLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  alias LiveCalendarWeb.Live.Calendar

  def render(assigns) do
    ~H"""
    <div class="days">
      <div class="grid grid-cols-7 gap-2 pb-3 auto-cols-auto font-medium text-center text-gray-500
    text-md dark:text-gray-400">
        <!-- Weekday Labels -->
        <span class="h-6 leading-6 dow">Su</span>
        <span class="h-6 leading-6 dow">Mo</span>
        <span class="h-6 leading-6 dow">Tu</span>
        <span class="h-6 leading-6 dow">We</span>
        <span class="h-6 leading-6 dow">Th</span>
        <span class="h-6 leading-6 dow">Fr</span>
        <span class="h-6 leading-6 dow">Sa</span>
      </div>
      <div class="grid grid-cols-7 auto-cols-auto days-of-month gap-1">
        <div
          :for={{date, calendar} <- @calendars}
          class={[
            "bg-gradient-to-br from-50% to-50% aspect-content aspect-[1/1] flex justify-center
            items-center text-sm font-semibold leading-9 text-center border rounded-md",
            classes(@calendars, calendar, @arrival_date, @departure_date)
          ]}
          phx-click="select_date"
          phx-value-date={date}
        >
          <span><%= calendar.date.day %></span>
        </div>
      </div>
    </div>
    <div class="mt-4">
      <span>Arrival Date: <%= @arrival_date %></span>
      <span>Departure Date: <%= @departure_date %></span>
    </div>
    """
  end

  defp classes(calendars, calendar, arrival_date, departure_date) do
    arrival = Map.get(calendars, arrival_date)
    departure = Map.get(calendars, departure_date)

    [
      date_classes(calendar, arrival, departure),
      availability_classes(calendar.available, calendar.previous_available, calendar.next_available)
    ]
  end

  @spec date_classes(Calendar.t(), Calendar.t() | nil, Calendar.t() | nil) :: String.t()
  defp date_classes(calendar, %Calendar{} = arrival, nil) do
    calendar.date == arrival.date && "!to-green-500"
  end

  defp date_classes(calendar, %Calendar{} = arrival, %Calendar{} = departure) do
    case {Date.compare(calendar.date, arrival.date), Date.compare(calendar.date, departure.date)} do
      {:eq, _} -> "!to-green-500"
      {_, :eq} -> "!from-green-500"
      {:gt, :lt} -> "!from-green-500 !to-green-500"
      {:lt, :gt} -> "!from-green-500 !to-green-500"
      _ -> ""
    end
  end

  defp date_classes(_, _, _) do
    ""
  end

  @spec availability_classes(self :: boolean, previous :: boolean, next :: boolean) :: binary
  defp availability_classes(false, true, _), do: "!from-white !to-gray-100"
  defp availability_classes(false, false, _), do: "!bg-gray-100 !text-gray-400"
  defp availability_classes(true, false, _), do: "!from-gray-100 !to-white-100"
  defp availability_classes(_, _, _), do: "from-white to-white"

  def mount(_params, _session, socket) do
    calendars = Map.new(Calendar.list_calendars(), fn calendar -> {to_string(calendar.date), calendar} end)

    {:ok,
     assign(socket,
       calendars: calendars,
       arrival_date: nil,
       departure_date: nil
     )}
  end

  def handle_event("select_date", %{"date" => date}, %{assigns: %{calendars: calendars}} = socket) do
    case calendars[date] do
      nil -> {:noreply, socket}
      calendar -> handle_select_date(calendar, date, socket)
    end
  end

  def handle_event("select_date", _, socket) do
    dbg(socket)
    {:noreply, socket}
  end

  defp handle_select_date(%Calendar{available: available, previous_available: previous_available}, selected_date, socket)
       when available or previous_available do
    case {socket.assigns.arrival_date, socket.assigns.departure_date} do
      {nil, nil} -> {:noreply, assign(socket, arrival_date: selected_date)}
      {nil, _} -> {:noreply, assign(socket, arrival_date: selected_date)}
      {_, nil} -> {:noreply, assign(socket, departure_date: selected_date)}
      {_, _} -> {:noreply, assign(socket, departure_date: selected_date)}
    end
  end

  defp handle_select_date(_, _, socket), do: {:noreply, socket}
end
