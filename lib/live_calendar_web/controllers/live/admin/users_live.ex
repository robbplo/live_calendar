defmodule LiveCalendarWeb.Live.Admin.UsersLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  alias LiveCalendar.User
  alias LiveCalendarWeb.LiveTable

  def render(assigns) do
    ~H"""
    <section class="p-3 sm:p-5">
      <div class="mx-auto max-w-screen-xl px-4 lg:px-12">
        <.live_component module={LiveTable} id="users_table" schema={User}>
          <:col :let={row} title="Email"><%= row.email %></:col>
          <:col :let={row} title="Name"><%= row.name %></:col>
          <:col :let={row} title="Role"><%= row.role %></:col>
        </.live_component>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {LiveCalendarWeb.Layouts, :admin}}
  end
end
