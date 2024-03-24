defmodule LiveCalendarWeb.Live.CalendarLiveStateTest do
  use ExUnit.Case, async: true

  alias LiveCalendar.Calendar
  alias LiveCalendarWeb.Live.CalendarLiveState

  test "new/1 returns a new state with empty arrival and departure dates" do
    state = CalendarLiveState.new(calendars())

    assert state.arrival == nil
    assert state.departure == nil
    assert %{"2024-03-01" => %Calendar{}} = state.calendars
  end

  test "reset/1 resets arrival and departure dates" do
    state = CalendarLiveState.new(calendars(), "2024-03-02", "2024-03-03")
    state = CalendarLiveState.reset(state)

    assert state.arrival == nil
    assert state.departure == nil
  end

  describe "select/2" do
    ### Both dates are nil
    test "does nothing if date is not found in state" do
      state = CalendarLiveState.new(calendars())
      state = CalendarLiveState.select(state, "2000-03-01")

      assert state.arrival == nil
      assert state.departure == nil
    end

    test "sets arrival when arrival and departure are nil" do
      state = CalendarLiveState.new(calendars())
      state = CalendarLiveState.select(state, "2024-03-02")

      assert state.arrival == "2024-03-02"
      assert state.departure == nil
    end

    test "does not set arrival if date is unavailable" do
      state = CalendarLiveState.new(calendars())
      state = CalendarLiveState.select(state, "2024-03-04")

      assert state.arrival == nil
      assert state.departure == nil
    end

    test "sets departure when arrival is set and departure is nil" do
      state = CalendarLiveState.new(calendars(), "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-03")

      assert state.arrival == "2024-03-02"
      assert state.departure == "2024-03-03"
    end

    test "sets departure if date is unavailable and previous date is available" do
      state = CalendarLiveState.new(calendars(), "2024-03-01")
      state = CalendarLiveState.select(state, "2024-03-04")

      assert state.arrival == "2024-03-01"
      assert state.departure == "2024-03-04"
    end

    test "does not set departure if previous date is unavailable" do
      state = CalendarLiveState.new(calendars(), "2024-03-01")
      state = CalendarLiveState.select(state, "2024-03-05")

      assert state.arrival == "2024-03-01"
      assert state.departure == nil
    end

    test "does not set departure if date is same as arrival and departure is nil" do
      state = CalendarLiveState.new(calendars(), "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-02")

      assert state.arrival == "2024-03-02"
      assert state.departure == nil
    end

    test "updates arrival when range contains unavailable dates and departure is nil" do
      state = CalendarLiveState.new(calendars(), "2024-03-01")
      state = CalendarLiveState.select(state, "2024-03-07")

      assert state.arrival == "2024-03-07"
      assert state.departure == nil
    end

    test "updates arrival when selected date is before arrival and departure is nil" do
      state = CalendarLiveState.new(calendars(), "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-01")

      assert state.arrival == "2024-03-01"
      assert state.departure == nil
    end

    ### Both dates are set
    test "updates arrival when selected date is before arrival" do
      state = CalendarLiveState.new(calendars(), "2024-03-02", "2024-03-03")
      state = CalendarLiveState.select(state, "2024-03-01")

      assert state.arrival == "2024-03-01"
      assert state.departure == "2024-03-03"
    end

    test "updates departure when selected date is after departure" do
      state = CalendarLiveState.new(calendars(), "2024-03-01", "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-03")

      assert state.arrival == "2024-03-01"
      assert state.departure == "2024-03-03"
    end

    test "updates arrival when range contains unavailable dates and departure is set" do
      state = CalendarLiveState.new(calendars(), "2024-03-01", "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-07")

      assert state.arrival == "2024-03-07"
      assert state.departure == nil
    end

    test "updates departure when selected date is in existing range" do
      state = CalendarLiveState.new(calendars(), "2024-03-01", "2024-03-03")
      state = CalendarLiveState.select(state, "2024-03-02")

      assert state.arrival == "2024-03-01"
      assert state.departure == "2024-03-02"
    end

    test "updates arrival when selected date is before arrival and departure is set" do
      state = CalendarLiveState.new(calendars(), "2024-03-02", "2024-03-03")
      state = CalendarLiveState.select(state, "2024-03-01")

      assert state.arrival == "2024-03-01"
      assert state.departure == "2024-03-03"
    end

    test "clears departure and sets arrival when range contains unavailable dates" do
      state = CalendarLiveState.new(calendars(), "2024-03-01", "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-07")

      assert state.arrival == "2024-03-07"
      assert state.departure == nil
    end

    test "clears arrival and sets departure when range contains unavailable dates - previous unavailable" do
      state = CalendarLiveState.new(calendars(), "2024-03-01", "2024-03-02")
      state = CalendarLiveState.select(state, "2024-03-06")

      assert state.arrival == "2024-03-06"
      assert state.departure == nil
    end
  end

  @spec calendars() :: [Calendar.t()]
  defp calendars do
    [
      {~D[2024-02-28], true},
      {~D[2024-03-01], true},
      {~D[2024-03-02], true},
      {~D[2024-03-03], true},
      {~D[2024-03-04], false},
      {~D[2024-03-05], false},
      {~D[2024-03-06], true},
      {~D[2024-03-07], true},
      {~D[2024-03-08], true},
      {~D[2024-03-09], true},
      {~D[2024-03-10], true},
      {~D[2024-03-11], true},
      {~D[2024-03-12], true},
      {~D[2024-03-13], true},
      {~D[2024-03-14], true},
      {~D[2024-03-15], true}
    ]
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{_, previous}, {date, available}] -> Calendar.new(date, available, previous) end)
  end
end
