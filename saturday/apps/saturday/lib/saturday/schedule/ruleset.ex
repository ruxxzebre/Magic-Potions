defmodule Saturday.Schedule.RuleSet.TimeRuleSet do
  defstruct day_of_week: 0,
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
  alias Saturday.Schedule.RuleSet.TimeRuleSet
  alias Saturday.Schedule.RuleSet

  defstruct date_from:
              Timex.now()
              |> Timex.set(
                year: 2022,
                month: 8,
                day: 1,
                hour: 0,
                minute: 0
              ),
            date_to:
              Timex.now()
              |> Timex.set(
                year: 2022,
                month: 9,
                day: 15,
                hour: 0,
                minute: 0
              ),
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

  @spec get_time_rule(%RuleSet{}, %DateTime{}) :: %TimeRuleSet{}
  def get_time_rule(%RuleSet{} = ruleset, %DateTime{} = date) do
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
    IO.inspect(date)
    # IO.inspect("date_from: #{ruleset.date_from}")
    # IO.inspect("date_to: #{ruleset.date_to}")
    comp_date_from = Timex.compare(ruleset.date_from, date)
    # must be 1 or 0
    comp_date_to = Timex.compare(ruleset.date_to, date)
    # IO.puts("comp_date_from: #{comp_date_from}. comp_date_to: #{comp_date_to}")
    # IO.puts("(comp_date_from == -1 || comp_date_from == 0) #{(comp_date_from == -1 || comp_date_from == 0)}")
    # IO.puts("(comp_date_to == 1 || comp_date_to == 0) #{(comp_date_to == 1 || comp_date_to == 0)}")
    # IO.puts("zero_num(date.minute / minute_interval) in for(i <- 0..entries_per_hour, do: i) #{zero_num(date.minute / minute_interval) in for(i <- 0..entries_per_hour, do: i)}")
    # IO.puts("date.hour >= time_rule.start_day_at.hour #{date.hour >= time_rule.start_day_at.hour}")
    # IO.puts("date.hour <= time_rule.end_day_at.hour #{date.hour <= time_rule.end_day_at.hour}")
    # IO.puts("date.minute*date.hour >= time_rule.start_day_at.minute #{date.hour >= time_rule.start_day_at.minute}")
    # IO.puts("date.minute*date.hour <= time_rule.end_day_at.minute #{date.hour <= time_rule.end_day_at.minute}")

    %{ start_day_at: start_day_at, end_day_at: end_day_at } = time_rule

    (comp_date_from == -1 || comp_date_from == 0) &&
      (comp_date_to == 1 || comp_date_to == 0) &&
      zero_num(date.minute / minute_interval) in for(i <- 0..entries_per_hour, do: i)
      date.hour >= start_day_at.hour &&
      date.hour <= end_day_at.hour &&
      date.minute + date.hour*60 >= start_day_at.minute + start_day_at.hour*60 &&
      date.minute + date.hour*60 <= end_day_at.minute + end_day_at.hour*60
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
