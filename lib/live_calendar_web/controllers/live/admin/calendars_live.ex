defmodule LiveCalendarWeb.Live.Admin.CalendarsLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  alias LiveCalendar.Calendar
  alias LiveCalendarWeb.LiveTable

  def render(assigns) do
    ~H"""
    <section class="p-3 sm:p-5">
      <div class="mx-auto max-w-screen-xl px-4 lg:px-12">
        <.live_component module={LiveTable} id="calendars_table" schema={Calendar}>
          <:col :let={row} title="Date"><%= row.date %></:col>
          <:col :let={row} title="Available"><%= row.available %></:col>
          <:col :let={row} title="Minimum stay"><%= row.minimum_stay %></:col>
        </.live_component>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {LiveCalendarWeb.Layouts, :admin}}
  end
end
