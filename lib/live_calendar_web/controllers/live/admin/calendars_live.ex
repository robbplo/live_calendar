defmodule LiveCalendarWeb.Live.Admin.CalendarsLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {LiveCalendarWeb.Layouts, :admin}}
  end
end
