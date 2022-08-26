defmodule Saturday.Schedule.Filters do
  def filter_weekends(date_list) do
    filter_date_by(date_list, :sunday?, false)
  end

  def filter_date_by(date_list, fun, positive \\ true) when is_atom(fun) do
    date_list
    |> Enum.filter(fn %{date: date} ->
      if positive do
        apply(__MODULE__, fun, [date])
      else
        not apply(__MODULE__, fun, [date])
      end
    end)
  end

  def nth_day_of_week?(date, n), do: Timex.local(date) |> Timex.weekday() == n

  def sunday?(date), do: nth_day_of_week?(date, 7)

  def friday?(date), do: nth_day_of_week?(date, 5)

  def satuday?(date), do: nth_day_of_week?(date, 6)
end
