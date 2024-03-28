defmodule LiveCalendarWeb.Live.AdminLive do
  @moduledoc false
  use LiveCalendarWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket, layout: {LiveCalendarWeb.Layouts, :admin}}
  end
end
