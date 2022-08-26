defmodule Saturday.Schedule.RuleSet do
  defstruct date_from: Timex.now(),
            date_to: Timex.now(),
            time_rules: %{
              specific: [
                %{
                  day_of_week: 5,
                  start_day_at_hour: 9,
                  end_day_at_hour: 16,
                  minute_interval: 15
                },
                %{
                  day_of_week: 6,
                  start_day_at_hour: 9,
                  end_day_at_hour: 14,
                  minute_interval: 15
                }
              ],
              fallback: %{
                start_day_at_hour: 9,
                end_day_at_hour: 18,
                minute_interval: 15
              }
            }

  def get_time_rule(%__MODULE__{} = ruleset, %DateTime{} = date) do
    rule = find_time_rule(ruleset.time_rules.specific, date)

    if rule == [] do
      ruleset.time_rules.fallback
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
      ((date.minute / minute_interval) in for i <- 0..entries_per_hour, do: i) &&
      true
  end
end
