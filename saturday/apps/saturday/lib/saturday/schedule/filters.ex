defmodule Saturday.Schedule.Filters do
  def filter_weekends(date_list) do
    filter_date_list_by(date_list, :sunday?, false)
  end

  def filter_date_by(date, fun, args \\ []) when is_atom(fun) do
    positive = Keyword.get(args, :positive, true)
    optional = Keyword.get(args, :optional, nil)
    pos_args = Keyword.get(args, :args, nil)

    args =
      if optional != nil do
        [date, optional]
      else
        [date]
      end

    args =
      if pos_args != nil do
        args ++ [pos_args]
      else
        args
      end

    if positive do
      apply(__MODULE__, fun, args)
    else
      not apply(__MODULE__, fun, args)
    end
  end

  def filter_date_list_by(date_list, fun, args \\ []) when is_atom(fun) do
    date_list
    |> Enum.filter(fn %{date: date} ->
      filter_date_by(date, fun, args)
    end)
  end

  def before_hour?(date, n) do
    date.hour < n
  end

  def after_hour?(date, n) do
    date.hour >= n
  end

  def between_hours?(date, [n1, n2]) do
    after_hour?(date, n1) && before_hour?(date, n2)
  end

  def nth_day_of_week?(date, n), do: Timex.local(date) |> Timex.weekday() == n

  def sunday?(date), do: nth_day_of_week?(date, 7)

  def friday?(date), do: nth_day_of_week?(date, 5)

  def satuday?(date), do: nth_day_of_week?(date, 6)

  def before_today?(date) do
    # now.year*now.month*now.day > date.year*date.month*date.day
    Timex.compare(date, Timex.local(), :day) == -1
    || Timex.compare(date, Timex.local(), :day) == 0
    || Timex.compare(date, Timex.local(), :days) == -1
    || Timex.compare(date, Timex.local(), :days) == 0

    # to_specific_timestamp(date) <= to_specific_timestamp(Timex.local())
  end

  defp to_specific_timestamp(date) do
    date.year*10000 + (date.month*100) + (date.day)
  end

  def same_as_today?(date) do
    Timex.compare(date, Timex.local(), :day) == 0
  end

  def batch_filters(date, filters) do
    filters
    |> Enum.reduce(0, fn
      {filter, positive, [args: args]}, acc ->
        acc +
          if filter_date_by(
               date,
               filter,
               [positive: positive, args: args]
             ) == true,
             do: 1,
             else: 0

      {filter, positive}, acc ->
        acc + if filter_date_by(date, filter, positive: positive) == true, do: 1, else: 0
    end) ==
      length(filters)
  end
end
