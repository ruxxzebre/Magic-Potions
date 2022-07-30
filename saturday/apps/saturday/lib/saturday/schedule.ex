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
  @enforce_keys [:date]
  defstruct [:date, booked: false]
end

defmodule Saturday.Schedule.Range do
  @enforce_keys [:date]
  defstruct [:date, date_forms: [""], localized_date: "", range: []]
end

defmodule Saturday.Schedule do
  alias Timex.Translator
  alias Saturday.Schedule.Filters
  alias Saturday.Schedule.Range
  alias Saturday.Schedule.RangeItem

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

  def filter_range(range, q \\ "", exclude_dates \\ []) do
    range
    |> Enum.filter(fn {date, %{localized_date: localized_date, date_forms: date_forms}} ->
      Enum.find(date_forms ++ [date, localized_date], fn date ->
        String.contains?(date, q)
      end)
    end)
    |> Enum.map(fn {date, %{range: range} = data} ->
      data = data
      |> Map.put(:range,
        range
        |> Enum.filter(fn entry ->
          date = entry.date
          date_to_spec(date) not in exclude_dates
        end)
      )

      {date, data}
    end)
  end

  @spec comp_dates(%DateTime{}, %DateTime{}) :: boolean()
  def comp_dates(d1, d2) do
    day1 = Date.day_of_year(d1)
    day2 = Date.day_of_year(d2)

    day1 == day2
    && d1.hour() == d1.hour()
    && d1.minute() == d2.minute()
  end

  def get_range do
    # shifted = get_shifted_dates(100);

    generate_range()
    |> Filters.filter_weekends()
    |> format_range()
    # |> filter_shifted(shifted)
  end

  def filter_shifted(range, shifted) do
    range |> Enum.map(fn {rdate, rval} ->
      rval = rval |> Map.put(:range,
        rval.range |> Enum.filter(fn inv ->
          Enum.find(shifted, fn shifted_date ->
            comp_dates(shifted_date, inv.date)
          end) == nil
        end)
      )
      {rdate, rval}
    end)
  end

  @interval 15
  @entries_per_hour trunc(60 / @interval)

  def get_shifted_dates(n \\ 10) do
    rarange = fn min, max -> floor(:rand.uniform()*(max - min)) + min end
    now = Timex.set(Timex.local(), hour: 9, minute: 0, second: 0, day: 2, month: 8)
    # |> IO.inspect

    # a = generate_range_min_max(2, 2)
    # IO.inspect a

    # hour = rarange.(9, 18)
    # minute = rarange.(3, 6)
    # day = rarange.(1, 15)

    # hour |> IO.inspect
    # minute |> IO.inspect
    # day |> IO.inspect
    # IO.inspect(n)
    for n <- 1..20 do
      get_shifted_date(now, 0, n)
    end
    # |> IO.inspect
  end

  def generate_shifted_dates(amount \\ 10) do

  end

  defp get_shifted_date(date, iterate_count, n) do
    case iterate_count do
      ^n -> date
      c ->
        date = Timex.shift(date, hours: c + 1, minutes: c * @interval, days: 1)
        get_shifted_date(date, c + 1, n)
    end
  end

  def generate_range() do
    generate_range(Timex.set(Timex.local(), hour: 9, minute: 0, second: 0))
  end

  @spec generate_range_min_max(%DateTime{}, %DateTime{}) :: []
  defp generate_range_min_max(min, max) do
    IO.inspect(min)
    IO.inspect(max)
    []
    # raise "Not implemented."
  end

  def generate_range(relative_to_date) do
    for day <- 1..5 do
      for hour <- 0..7 do
        for minute <- 1..@entries_per_hour do
          %{
            date: Timex.shift(relative_to_date, hours: hour, minutes: minute * @interval, days: day),
            booked: false
          }
        end
      end
    end
    |> List.flatten()
  end

  def date_to_spec(%DateTime{} = date) do
    spec_map = Saturday.DateUtils.date_spec_map(date)
    zeroify = &(if &1 > 9, do: &1, else: "0#{&1}")
    "#{zeroify.(spec_map.day)}.#{zeroify.(spec_map.month)}"
    <> ".#{spec_map.year}-#{zeroify.(date.hour)}"
    <> ".#{zeroify.(date.minute)}"
  end

  # defp traverse_date_spec([date | time]) do
  #
  # end

  def date_from_spec(date_spec) do
    date_spec
    |> String.split("-")
    |> Enum.map(&(String.split(&1, ".")))
    |> Enum.with_index()
    |> Enum.reduce(%{ year: 0, month: 0, day: 0, minute: 0, hour: 0 },
      fn {curr, index}, acc ->
        case index do
          0 ->
            day = hd(curr)
            month = hd(tl(curr))
            year = hd(tl(tl(curr)))
            %{ acc | day: day, month: month, year: year }
          1 ->
            hour = hd(curr)
            minute = hd(tl(curr))
            %{ acc | hour: hour, minute: minute }
        end
      end)
  end
end
