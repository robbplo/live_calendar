defmodule LiveCalendar.Repo do
  use Ecto.Repo,
    otp_app: :live_calendar,
    adapter: Ecto.Adapters.SQLite3
end
