defmodule Saturday.Schedule.Validators.ComparisonMap do
  defstruct date_form: ""
end

defmodule Saturday.Schedule.Validators do
  alias Saturday.Schedule
  alias Saturday.Schedule.Validators.ComparisonMap

  def validate_entry_date(date, %ComparisonMap{} = comparison_map) when is_binary(date) do
    Schedule.date_from_spec(date)
    |> validate_entry_date(comparison_map)
  end

  def validate_entry_date(date, %ComparisonMap{} = comparison_map) do
    true
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
  @moduledoc """
  Schedule range management.
  Used for generation and processing of date ranges from and to certain date,
  as well as from and to certain hour:minute.
  """

  alias Timex.Translator
  alias Saturday.Schedule.Filters
  alias Saturday.Schedule.RuleSet
  # alias Saturday.Schedule.Range
  # alias Saturday.Schedule.RangeItem

  def format_date!(date, opts \\ [])

  def format_date!(date, opts) when is_binary(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{D}") do
      {:error, _} -> format_date!(date_from_spec(date), opts)
      {:ok, date} -> format_date!(date, opts)
    end

    # with {:ok, date} <- Timex.parse!(date, "{YYYY}-{OM}-{D}"),
    # do
    # end
  end

  def format_date!(date, opts) do
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

    date_string =
      "#{String.capitalize(weekday)}. #{local_date.day()} #{String.capitalize(month)} #{local_date.year()}"

    if Keyword.get(opts, :with_time, false) do
      date_string <> ". #{zeroify(local_date.hour())}:#{zeroify(local_date.minute())}"
    else
      date_string
    end
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
    |> Enum.reduce(%{}, fn date, acc ->
      fom = Timex.format!(date, "{YYYY}-{0M}-{0D}")
      Map.put(acc, fom, Map.get(acc, fom, []) ++ [date])
    end)
    |> Enum.map(fn {date, range} ->
      parsed = Timex.parse!(date, "{YYYY}-{0M}-{0D}")

      {date,
       %{
         date_struct: parsed,
         range: range,
         localized_date: format_date!(date),
         date_forms: [
           Timex.format!(parsed, "{YYYY}.{0M}.{0D}"),
           Timex.format!(parsed, "{0D}.{0M}.{YYYY}")
         ]
       }}
    end)
    |> Enum.sort(fn {_, %{date_struct: d1}}, {_, %{date_struct: d2}} ->
      Timex.compare(d1, d2) == -1
    end)
  end

  def filter_range(range, q \\ "", exclude_dates \\ []) do
    range
    |> Enum.filter(fn {date, %{localized_date: localized_date, date_forms: date_forms}} ->
      Enum.find(date_forms ++ [date, localized_date], fn date ->
        String.contains?(String.downcase(date), String.downcase(q))
      end)
    end)
    |> Enum.map(fn {date, %{range: range} = data} ->
      data =
        data
        |> Map.put(
          :range,
          range
          |> Enum.filter(fn date ->
            date_to_spec(date) not in exclude_dates
          end)
        )

      {date, data}
    end)
    |> Enum.filter(fn {_, %{range: range}} ->
      length(range) > 0
    end)
  end

  @spec comp_dates(%DateTime{}, %DateTime{}) :: boolean()
  def comp_dates(d1, d2) do
    day1 = Date.day_of_year(d1)
    day2 = Date.day_of_year(d2)

    day1 == day2 &&
      d1.hour() == d1.hour() &&
      d1.minute() == d2.minute()
  end

  @doc """
  Get generated range of dates starting from now.
  """
  @spec get_range() :: [binary()]
  def get_range do
    range =
      generate_range(Saturday.ConfigStorage.get_data(:ruleset))
      |> Filters.filter_date_list_by(:batch_filters,
        optional: [
          {:sunday?, false},
          {:before_today?, false},
          {:between_hours?, false, args: [13, 14]},
          {:same_as_today?, false}
        ]
      )
      |> format_range()

    range
  end

  def filter_shifted(range, shifted) do
    range
    |> Enum.map(fn {rdate, rval} ->
      rval =
        rval
        |> Map.put(
          :range,
          rval.range
          |> Enum.filter(fn inv ->
            is_nil(
              Enum.find(shifted, fn shifted_date ->
                comp_dates(shifted_date, inv.date)
              end)
            )
          end)
        )

      {rdate, rval}
    end)
  end

  @interval 15
  @entries_per_hour trunc(60 / @interval)

  def generate_range_from_to2(%Date{} = from, %Date{} = to, %RuleSet{} = ruleset) do
    from = Timex.to_datetime(from)
    to = Timex.to_datetime(to)
    generate_range_from_to2(from, to, ruleset)
  end

  def generate_range_from_to2(%DateTime{} = from, %DateTime{} = to, %RuleSet{} = ruleset) do
    r = ruleset
  end

  defp gen_range_rec(
         from,
         to,
         %RuleSet{} = ruleset,
         current_date \\ nil,
         buf \\ []
       ) do
    current_date = if is_nil(current_date), do: from, else: current_date

    minute_interval = 2
    date = current_date |> Timex.shift(minutes: minute_interval)
    time_rule = RuleSet.get_time_rule(ruleset, date)

    gen_range_rec(date, from, to, [date | buf])
  end

  @spec generate_range(%RuleSet{}) :: []
  defp generate_range(%RuleSet{} = ruleset) do
    from = ruleset.date_from
    to = ruleset.date_to
    days_amount = Date.day_of_year(to) - Date.day_of_year(from) - 1
    date_from_time_rule = RuleSet.get_time_rule(ruleset, from)

    # TODO: optimize with (recursion?)
    return =
      for day <- 0..days_amount do
        date =
          from
          |> Timex.set(Enum.into(date_from_time_rule.start_day_at, []))
          |> Timex.shift(days: day)

        time_rule = RuleSet.get_time_rule(ruleset, date)
        hours_amount = time_rule.end_day_at.hour - time_rule.start_day_at.hour - 1
        entries_per_hour = trunc(60 / time_rule.minute_interval)

        for hour <- 0..hours_amount do
          date = Timex.shift(date, hours: hour)

          for minute <- 0..(entries_per_hour - 1) do
            Timex.shift(date, minutes: minute * @interval)
          end
        end
      end
      |> List.flatten()

    return
    |> Enum.filter(fn date ->
      not RuleSet.excluded?(ruleset, date)
    end)
  end

  defp sort_range(_range) do
    # range
    # |> Enum.sort(&(Date.compare(&1.date, &2.date) != :lt))
    # |> Enum.sort(&(DateTime.compare(&1.date, &2.date) != :gt))

    raise "Not implemented"
  end

  # ! DEPRECATED
  def generate_range_dep(relative_to_date) do
    for day <- 1..5 do
      for hour <- 0..7 do
        for minute <- 1..@entries_per_hour do
          %{
            date:
              Timex.shift(relative_to_date, hours: hour, minutes: minute * @interval, days: day),
            booked: false
          }
        end
      end
    end
    |> List.flatten()
  end

  def zeroify(thing) when is_binary(thing), do: String.to_integer(thing)

  def zeroify(thing) do
    if thing > 9, do: thing, else: "0#{thing}"
  end

  def date_to_spec(%DateTime{} = date) do
    spec_map = Saturday.DateUtils.date_spec_map(date)

    "#{zeroify(spec_map.day)}.#{zeroify(spec_map.month)}" <>
      ".#{spec_map.year}-#{zeroify(date.hour)}" <>
      ".#{zeroify(date.minute)}"
  end

  @spec_regex ~r/((\w{2})\.(\w{2})\.(\w{4})\-(\w{2})\.\w{2})/

  def validate_spec_date(date_spec) do
    String.match?(date_spec, @spec_regex)
  end

  def date_from_spec(date_spec, to_datetime \\ false)

  def date_from_spec(date_spec, to_datetime) do
    parsed =
      date_spec
      |> String.split("-")
      |> Enum.map(&String.split(&1, "."))
      |> Enum.with_index()
      |> Enum.reduce(
        %{year: 0, month: 0, day: 0, minute: 0, hour: 0},
        fn {curr, index}, acc ->
          case index do
            0 ->
              day = hd(curr)
              month = hd(tl(curr))
              year = hd(tl(tl(curr)))
              %{acc | day: day, month: month, year: year}

            1 ->
              hour = hd(curr)
              minute = hd(tl(curr))
              %{acc | hour: hour, minute: minute}
          end
        end
      )

    if to_datetime do
      Timex.now()
      |> Timex.set(
        parsed
        |> Enum.map(fn {a, b} -> {a, String.to_integer(b)} end)
        |> Enum.into([])
      )
    else
      parsed
    end
  end
end
