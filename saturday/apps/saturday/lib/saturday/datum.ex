defmodule Saturday.Datum do
  @moduledoc """
  Handy date management used to avoid issues with comparing dates,
  timezones, etc.
  """
  require Logger

  @default_timezone "Europe/Kiev"

  def to_local(date), do: date |> Timex.to_datetime(@default_timezone)

  def naive_to_datetime(date) do
    DateTime.from_naive!(date, "Etc/UTC")
    |> Timex.to_datetime(@default_timezone)
  end

  def now() do
    Timex.now(@default_timezone)
  end

  def new_date([year, month, day]) do
    new_date(year, month, day)
  end

  def new_date([year, month, day, hour, minute]) do
    new_date(year, month, day, hour, minute)
  end

  def new_date(year, month, day, hour, minute) do
    date = new_date(year, month, day)
    # time = new_time(hour, minute)

    date
    |> Timex.set(
      hour: hour,
      minute: minute
    )
  end

  def new_date(year, month, day) do
    {:ok, date} = Date.new(year, month, day)

    date
    |> Timex.to_datetime(@default_timezone)
    |> Timex.set(
      year: year,
      month: month,
      day: day
    )
  end

  def new_time([hour, minute]) do
    new_time(hour, minute)
  end

  def new_time(hour, minute) do
    {:ok, time} = Time.new(hour, minute, 0, 0)
    time
  end

  def cut_time(date) do
    new_date(date.year, date.month, date.day)
  end

  # def is_passed(d1, d2, hr) do
  #   Timex.compare(d1, d2, :hours)
  # end

  def comp_pure_dates(d1, d2) do
    cond do
      d1 == nil ->
        false

      d2 == nil ->
        false

      true ->
        date = d1
        el = d2
        date.year == el.year && date.month == el.month && date.day == el.day
    end
  end
end
