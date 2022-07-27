defmodule Saturday.Schedule.Filters do
  def filter_weekends(date_list) do
    date_list
    |> Enum.filter(fn %{date: date} ->
      weekday = Timex.local(date) |> Timex.weekday()
      weekday not in [6, 7]
    end)
  end
end

defmodule Saturday.Schedule.RangeItem do
  defstruct date:
              %{
                # range: [%Timex.Date{}]
              }
end

defmodule Saturday.Schedule do
  alias Timex.Translator
  alias Saturday.Schedule.Filters

  def format_date!(date) when is_binary(date) do
    format_date!(Timex.parse!(date, "{YYYY}-{0M}-{D}"))
  end

  def format_date!(date) do
    local_date = Timex.local(date)

    translate_weekday = fn name -> Translator.translate("uk", "weekdays", name) end
    translate_month = fn name -> Translator.translate("uk", "months", name) end

    weekday =
      local_date
      |> Timex.weekday()
      |> Timex.day_name()
      |> translate_weekday.()

    month =
      local_date.month()
      |> Timex.month_name()
      |> translate_month.()

    "#{String.capitalize(weekday)}. #{local_date.day()} #{String.capitalize(month)} #{local_date.year()}"
  end

  def format_time(date) do
    # Presume that date is already local
    local_date = date
    hour = if local_date.hour() > 9, do: local_date.hour(), else: "0#{local_date.hour()}"
    minute = if local_date.minute() > 9, do: local_date.minute(), else: "0#{local_date.minute()}"
    "#{hour}:#{minute}"
  end

  # def form_full_date(year, month, day, hour \\ 0, minute \\ 0, second \\ 0) do
  #   Timex.to_datetime({{year, month, day}, {hour, minute, second}})
  # end

  def format_range(range) do
    range
    |> Enum.reduce(%{}, fn elem, acc ->
      fom = Timex.format!(elem.date, "{YYYY}-{0M}-{D}")
      Map.put(acc, fom, Map.get(acc, fom, []) ++ [elem])
    end)
    |> Enum.map(fn {date, range} ->
      parsed = Timex.parse!(date, "{YYYY}-{0M}-{D}")

      {date,
       %{
         range: range,
         localized_date: format_date!(date),
         date_forms: [
           Timex.format!(parsed, "{YYYY}.{0M}.{D}"),
           Timex.format!(parsed, "{D}.{0M}.{YYYY}")
         ]
       }}
    end)
  end

  def filter_range(range, q \\ "") do
    range
    |> Enum.filter(fn {date, %{localized_date: localized_date, date_forms: date_forms}} ->
      Enum.find(date_forms ++ [date, localized_date], fn date ->
        String.contains?(date, q)
      end)
    end)
  end

  def get_range do
    generate_range()
    |> Filters.filter_weekends()
    |> format_range()
  end

  @interval 15
  @entries_per_hour trunc(60 / @interval)

  def generate_range, do: get_range_()

  defp get_range_() do
    now = Timex.set(Timex.local(), hour: 9, minute: 0, second: 0)

    for day <- 1..5 do
      for hour <- 0..7 do
        for minute <- 0..@entries_per_hour do
          %{
            date: Timex.shift(now, hours: hour, minutes: minute * @interval, days: day),
            booked: false
          }
        end
      end
    end
    |> List.flatten()
  end
end
