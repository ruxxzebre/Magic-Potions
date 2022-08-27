defmodule Saturday.Schedule.RuleSet.TimeRuleSet do
  defstruct day_of_week: 0,
            start_day_at_hour: 0,
            end_day_at_hour: 0,
            minute_interval: 0
end

defmodule Saturday.Schedule.RuleSet do
  alias Saturday.Schedule.RuleSet.TimeRuleSet

  defstruct date_from:
              Timex.now()
              |> Timex.set(
                year: 2022,
                month: 8,
                day: 20
              ),
            date_to:
              Timex.now()
              |> Timex.set(
                year: 2022,
                month: 9,
                day: 20
              ),
            time_rules: %{
              specific: [
                %TimeRuleSet{
                  day_of_week: 5,
                  start_day_at_hour: 9,
                  end_day_at_hour: 16,
                  minute_interval: 15
                },
                %TimeRuleSet{
                  day_of_week: 6,
                  start_day_at_hour: 9,
                  end_day_at_hour: 14,
                  minute_interval: 15
                }
              ],
              fallback: %TimeRuleSet{
                start_day_at_hour: 9,
                end_day_at_hour: 18,
                minute_interval: 15
              }
            }

  def get_time_rule(%__MODULE__{} = ruleset, %DateTime{} = date) do
    rule = find_time_rule(ruleset.time_rules.specific, date)

    if rule == [] do
      ruleset.time_rules.fallback
    else
      rule
    end
  end

  defp find_time_rule([head | tail], %DateTime{} = date) do
    if Timex.weekday(date) == head.day_of_week do
      head
    else
      if tail == [] do
        []
      else
        find_time_rule(tail, date)
      end
    end
  end

  def validate_date_against_ruleset(%__MODULE__{} = ruleset, %DateTime{} = date) do
    time_rule = get_time_rule(ruleset, date)
    minute_interval = time_rule.minute_interval
    entries_per_hour = trunc(60 / minute_interval)

    # must be -1 or 0
    comp_date_from = Timex.compare(ruleset.date_from, date)
    # must be 1 or 0
    comp_date_to = Timex.compare(ruleset.date_to, date)

    (comp_date_from == -1 || comp_date_from == 0) &&
      (comp_date_to == 1 || comp_date_to == 0) &&
      zero_num(date.minute / minute_interval) in for(i <- 0..entries_per_hour, do: i) &&
      date.hour >= time_rule.start_day_at_hour &&
      date.hour <= time_rule.end_day_at_hour
  end

  def is_zero(number) when is_number(number) do
    number == trunc(number)
  end

  def zero_num(number) when is_number(number) do
    if is_zero(number) do
      trunc(number)
    else
      number
    end
  end
end
