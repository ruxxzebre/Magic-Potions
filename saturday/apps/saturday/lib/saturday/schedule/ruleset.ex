defmodule Saturday.Schedule.RuleSet.TimeRuleSet do
  defstruct day_of_week: 0,
            date: nil,
            minute_interval: 0,
            start_day_at: %{
              hour: 0,
              minute: 0
            },
            end_day_at: %{
              hour: 0,
              minute: 0
            }
end

defmodule Saturday.Schedule.RuleSet do
  alias Saturday.Datum
  alias Saturday.Schedule.RuleSet
  alias Saturday.Schedule.RuleSet.TimeRuleSet

  defstruct date_from: nil,
            date_to: nil,
            date_rules: %{
              exclude: []
            },
            time_rules: %{
              specific: [
                %TimeRuleSet{
                  day_of_week: 5,
                  start_day_at: %{
                    hour: 9,
                    minute: 0
                  },
                  end_day_at: %{
                    hour: 16,
                    minute: 0
                  },
                  minute_interval: 15
                },
                %TimeRuleSet{
                  day_of_week: 6,
                  start_day_at: %{
                    hour: 9,
                    minute: 0
                  },
                  end_day_at: %{
                    hour: 14,
                    minute: 0
                  },
                  minute_interval: 15
                }
              ],
              fallback: %TimeRuleSet{
                minute_interval: 15,
                start_day_at: %{
                  hour: 9,
                  minute: 0
                },
                end_day_at: %{
                  hour: 18,
                  minute: 0
                }
              }
            }

  def new_default_ruleset() do
    rs = %RuleSet{}

    date_rules = %{
      exclude: [
        Datum.new_date(2022, 9, 3)
      ]
    }

    time_rules =
      rs.time_rules
      |> Map.update(:specific, rs.time_rules.specific, fn rules ->
        [
          %TimeRuleSet{
            date: Datum.new_date(2023, 12, 23),
            start_day_at: %{
              hour: 9,
              minute: 0
            },
            end_day_at: %{
              hour: 14,
              minute: 0
            },
            minute_interval: 15
          }
          | rules
        ]
      end)

    rs
    |> Map.put(:date_from, Datum.new_date(2023, 7, 20, 0, 0))
    |> Map.put(:date_to, Datum.new_date(2023, 8, 30, 0, 0))
    |> Map.put(:date_rules, date_rules)
    |> Map.put(:time_rules, time_rules)
  end

  def excluded?(ruleset, date) do
    ruleset.date_rules.exclude
    |> Enum.reduce(0, fn el, acc ->
      flag = date.year == el.year && date.month == el.month && date.day == el.day
      acc + if flag, do: 1, else: 0
    end) > 0
  end

  @spec get_time_rule(%RuleSet{}, %DateTime{}) :: %TimeRuleSet{}
  def get_time_rule(ruleset, %DateTime{} = date) do
    rule = find_time_rule(ruleset.time_rules.specific, date)

    if rule == [] do
      ruleset.time_rules.fallback
    else
      rule
    end
  end

  defp find_time_rule([head | tail], %DateTime{} = date) do
    cond do
      Datum.comp_pure_dates(date, head.date) ->
        head

      Timex.weekday(date) == head.day_of_week ->
        head

      tail == [] ->
        []

      true ->
        find_time_rule(tail, date)
    end
  end

  def validate_date_against_ruleset(%__MODULE__{} = ruleset, %DateTime{} = date) do
    time_rule = get_time_rule(ruleset, date)
    minute_interval = time_rule.minute_interval
    entries_per_hour = trunc(60 / minute_interval)

    comp_date_from = Timex.compare(ruleset.date_from, date)
    comp_date_to = Timex.compare(ruleset.date_to, date)

    %{start_day_at: start_day_at, end_day_at: end_day_at} = time_rule

    (comp_date_from == -1 || comp_date_from == 0) &&
      (comp_date_to == 1 || comp_date_to == 0) &&
      Integer.mod(date.minute, minute_interval) == 0 &&
      date.minute / minute_interval <= entries_per_hour &&
      date.hour >= start_day_at.hour &&
      date.hour <= end_day_at.hour &&
      date.minute + date.hour * 60 >= start_day_at.minute + start_day_at.hour * 60 &&
      date.minute + date.hour * 60 <= end_day_at.minute + end_day_at.hour * 60
  end

  defp is_zero(number) when is_number(number) do
    number == trunc(number)
  end

  defp zero_num(number) when is_number(number) do
    if is_zero(number) do
      trunc(number)
    else
      number
    end
  end
end
